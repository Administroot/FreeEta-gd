use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

#[derive(Serialize, Deserialize)]
struct Component {
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
pub struct System {
    components: Vec<Component>,
}

impl System {
    pub fn new() -> Self {
        System { components: vec![Component::new()] }
    }
}

fn deserialize_system(json_str: &str) -> Result<System, serde_json::Error> {
    let system: System = serde_json::from_str(json_str)?;
    Ok(system)
}

pub fn deserialize_system_from_path(path: &Path) -> Result<System, Box<dyn std::error::Error>> {
    let json_str = fs::read_to_string(path)?;
    let system = deserialize_system(&json_str)?;
    Ok(system)
}

fn serialize_system(system: &System) -> Result<String, serde_json::Error> {
    let json_str = serde_json::to_string_pretty(system)?;
    Ok(json_str)
}

pub fn serialize_system_to_path(system: &System, path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let json_str = serialize_system(system)?;
    fs::write(path, json_str)?;
    Ok(())
}