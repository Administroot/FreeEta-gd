use godot::classes::{file_access::ModeFlags, Node};
use godot::prelude::*;
use crate::common::algorithm;
use crate::model::IData;

#[derive(GodotClass)]
#[class(base=Node)]
#[allow(dead_code)]
struct Calculator {
    idata: IData,
    base: Base<Node>,
}

use godot::classes::{INode, FileAccess};

#[godot_api]
impl INode for Calculator {
    fn init(base: Base<Node>) -> Self {
        Self { idata: IData::initialize("user://saves/components.json"), base }
    }

    fn ready(&mut self) {
        self.generate_eta_data();
    }
}

#[godot_api]
impl Calculator {
    #[func]
    fn generate_eta_data(&mut self){
        let _odata = algorithm(&mut self.idata);
        self.signals().calculator_prepared().emit();
    }

    #[signal]
    fn calculator_prepared();
}

impl IData {
    fn initialize(path: &str) -> Self {
        let file = FileAccess::open(path, ModeFlags::READ)
            .ok_or("Failed to open save file").unwrap();
        let content = file.get_as_text();

        let mut data = IData::new();
        match data.deserialize_gstring(&content) {
            Ok(_) => {},
            Err(e) => godot_error!("Deserialize stage failed: {}", e),
        }
        data
    }

    fn deserialize_gstring(&mut self, txt: &GString) -> Result<(), Box<dyn std::error::Error>> {
        match serde_json::from_str::<IData>(&txt.to_string()) {
            Ok(parsed) => {
                *self = parsed;
                Ok(())
            }
            Err(e) => Err(Box::new(e)),
        }
    }
}