use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;
use std::collections::HashMap;
use toml;

#[derive(Serialize, Deserialize)]
pub struct Component {
    node_id: i64,
    node_name: String,
    node_type: String,
    prev_node: Vec<i64>,
    reliability: f64,
}

impl Component {
    pub fn new() -> Self {
        Component { node_id: 1024, node_name: String::from("new_node"), node_type: String::from("new_node_type"), prev_node: Vec::new(), reliability: 1f64 }
    }
}


#[derive(Serialize, Deserialize)]
pub struct IData {
    pub components: Vec<Component>,
}

impl IData {

    pub fn deserialize(&mut self, path: &Path) -> Result<(), Box<dyn std::error::Error>>{
        let ext = path.extension()
            .and_then(|e| e.to_str())
            .unwrap_or("")
            .to_ascii_lowercase();
        let content = fs::read_to_string(path)?;
        let idata = match ext.as_str() {
            "json" => { 
                let system = serde_json::from_str(&content)?;
                system
            },
            "toml" => {
                let system: IData = toml::from_str(&content)?;
                system
            },
            _ => {
                let msg = format!("Unsupported file extension {}!", &ext);
                return Err(msg.into());
            },
        };
        *self = idata;
        Ok(())
    }

    pub fn to_etanode(&self) -> ETANode {
        // Build successor map
        let mut successors: HashMap<i64, Vec<i64>> = HashMap::new();
        for comp in &self.components {
            for &prev_id in &comp.prev_node {
                successors.entry(prev_id).or_default().push(comp.node_id);
            }
        }
        
        // Build `Component` map
        let comp_map: HashMap<_, _> = self.components.iter()
            .map(|c| (c.node_id, c))
            .collect();
        
        // Recursivlly build event tree
        self.build_etanode(0, &comp_map, &successors)
    }
    
    fn build_etanode(
        &self,
        node_id: i64,
        comp_map: &HashMap<i64, &Component>,
        successors: &HashMap<i64, Vec<i64>>
    ) -> ETANode {
        // Terminate processing
        if node_id == -1 {
            return ETANode::Outcome {
                name: "Ending".into(),
                impact: 0.0
            };
        }
        
        let comp = comp_map[&node_id];
        let succ_list = successors.get(&node_id).cloned().unwrap_or_default();
        
        // Handle different subsequent nodes
        match succ_list.len() {
            // No subsequence -> Failure
            0 => ETANode::Outcome {
                name: self.get_failure_name(&comp.node_name),
                impact: self.get_impact(&comp.node_name)
            },
            
            // One subsequence
            1 => {
                let next_id = succ_list[0];
                let next_node = self.build_etanode(next_id, comp_map, successors);
                
                // Failure node
                let failure_node = ETANode::Outcome {
                    name: self.get_failure_name(&comp.node_name),
                    impact: self.get_impact(&comp.node_name)
                };
                
                // Build event node
                let mut event = ETANode::Event {
                    name: comp.node_name.clone(),
                    success_prob: comp.reliability,
                    failure_prob: 1.0 - comp.reliability,
                    success_child: Some(Box::new(next_node)),
                    failure_child: Some(Box::new(failure_node))
                };
                
                // Reliability == 1.0, no failure branch
                if comp.reliability == 1.0 {
                    if let ETANode::Event { failure_child, .. } = &mut event {
                        *failure_child = None;
                    }
                }
                event
            }
            
            // Multiple subsequences (Take the first two nodes)
            _ => {
                let mut sorted_succ = succ_list.clone();
                sorted_succ.sort_unstable();
                
                let next_id_success = sorted_succ[0];
                let next_id_failure = sorted_succ[1];
                
                ETANode::Event {
                    name: comp.node_name.clone(),
                    success_prob: comp.reliability,
                    failure_prob: 1.0 - comp.reliability,
                    success_child: Some(Box::new(
                        self.build_etanode(next_id_success, comp_map, successors)
                    )),
                    failure_child: Some(Box::new(
                        self.build_etanode(next_id_failure, comp_map, successors)
                    ))
                }
            }
        }
    }
    
    // TODO: Customize the name
    fn get_failure_name(&self, node_name: &str) -> String {
        match node_name {
            "Pump" => "System_Shutdown".into(),
            "ValveB" => "ValveB_Failure".into(),
            "ValveC" => "ValveC_Failure".into(),
            "ValveD" => "Partial_Failure".into(),
            _ => format!("{node_name}_Failure")
        }
    }
    
    // TODO: Customize the impact
    fn get_impact(&self, node_name: &str) -> f64 {
        match node_name {
            "Pump" => 0.8,
            "ValveB" | "ValveC" => 0.7,
            "ValveD" => 0.5,
            _ => 0.5
        }
    }
}

#[derive(Debug, Clone)]
pub enum ETANode {
    Event {
        name: String,
        success_prob: f64, 
        #[allow(dead_code)]
        failure_prob: f64,
        success_child: Option<Box<ETANode>>,
        failure_child: Option<Box<ETANode>>,
    },
    Outcome {
        name: String,
        impact: f64,
    },
}


impl ETANode {
    // Generate all possible paths, probabilities and outcomes
    pub fn generate_paths(&self) -> Vec<(Vec<String>, f64, f64)> {
        let mut paths = Vec::new();
        self._dfs(&mut Vec::new(), 1.0, &mut paths);
        paths
    }

    // Traversing event tree
    fn _dfs(&self, current_path: &mut Vec<String>, current_prob: f64, paths: &mut Vec<(Vec<String>, f64, f64)>) {
        match self {
            ETANode::Event { name, success_prob, success_child, failure_child, .. } => {
                // Success branch
                current_path.push(format!("{}:Success", name));
                if let Some(child) = success_child {
                    child._dfs(current_path, current_prob * success_prob, paths);
                }
                current_path.pop();

                // Failure branch
                current_path.push(format!("{}:Failure", name));
                if let Some(child) = failure_child {
                    child._dfs(current_path, current_prob * (1.0 - success_prob), paths);
                }
                current_path.pop();
            }
            ETANode::Outcome { name, impact } => {
                let _ = name;
                // Record current_path result
                paths.push((current_path.clone(), current_prob, *impact));
            }
        }
    }
}

#[derive(Serialize, Deserialize)]
#[allow(dead_code)]
pub struct EtaPath {
    path: HashMap<String, bool>,
    prob: f64,
    impact: f64,
}

impl EtaPath {
    pub fn new(path: HashMap<String, bool>, prob: f64, impact: f64) -> Self{
        Self { path, prob, impact }
    }
}

#[derive(Serialize, Deserialize)]
pub struct OData {
    pub etapaths: Vec<EtaPath>,
}

impl OData {
    pub fn new() -> Self {
        Self { etapaths: vec![] }
    }

    pub fn serialize(&self, path: &Path) -> Result<(),  Box<dyn std::error::Error>>{
        let ext = path.extension()
            .and_then(|e| e.to_str())
            .unwrap_or("")
            .to_ascii_lowercase();
        match ext.as_str() {
            "json" => {
                let json_str = serde_json::to_string_pretty(self)?;
                fs::write(path, json_str)?;
            },
            "toml" => {
                let toml_str = toml::to_string_pretty(self)?;
                fs::write(path, toml_str)?;
            },
            _ => return Err(format!("Unsupported file extension: {}", ext).into()),
        }
        Ok(())
    }
}