use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;
use csv;
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
pub struct System {
    pub components: Vec<Component>,
}

impl System {
    pub fn new() -> Self {
        System { components: vec![Component::new()] }
    }
}

pub fn deserialize_system_from_path(path: &Path) -> Result<System, Box<dyn std::error::Error>> {
    let ext = path.extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_ascii_lowercase();

    let content = fs::read_to_string(path)?;

    let system = match ext.as_str() {
        "json" => { 
            let system = serde_json::from_str(&content)?;
            system
        },
        "csv" => {
            let mut rdr = csv::Reader::from_reader(content.as_bytes());
            let components: Vec<Component> = rdr.deserialize().collect::<Result<_, _>>()?;
            System { components }
        },
        "toml" => {
            let system: System = toml::from_str(&content)?;
            system
        },
        _ => return Err(format!("Unsupported file extension: {}", ext).into()),
    };

    Ok(system)
}

pub fn serialize_system_to_path(system: &System, path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let ext = path.extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_ascii_lowercase();

    match ext.as_str() {
        "json" => {
            let json_str = serde_json::to_string_pretty(system)?;
            fs::write(path, json_str)?;
        },
        "csv" => {
            let mut wtr = csv::Writer::from_writer(vec![]);
            for component in &system.components {
                wtr.serialize(component)?;
            }
            let data = String::from_utf8(wtr.into_inner()?)?;
            fs::write(path, data)?;
        },
        "toml" => {
            let toml_str = toml::to_string_pretty(system)?;
            fs::write(path, toml_str)?;
        },
        _ => return Err(format!("Unsupported file extension: {}", ext).into()),
    }
    Ok(())
}