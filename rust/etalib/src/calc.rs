use godot::classes::{ file_access::ModeFlags, Node };
use godot::prelude::*;
use crate::common::algorithm;
use crate::model::{ IData, OData };

#[derive(GodotClass)]
#[class(base = Node)]
#[allow(dead_code)]
pub struct Calculator {
    idata: IData,
    odata: OData,
    base: Base<Node>,
}

use godot::classes::{ Control, FileAccess, INode };

#[godot_api]
impl INode for Calculator {
    fn init(base: Base<Node>) -> Self {
        Self { idata: IData::initialize("user://saves/components.json"), odata: OData::new(), base }
    }

    fn ready(&mut self) {
        self.signals().start_calculation().connect_self(Self::main_calculation);
        // Manually emit signal
        // self.signals().start_calculation().emit();
    }
}

#[godot_api]
impl Calculator {
    #[func]
    fn main_calculation(&mut self) {
        let parent = if let Some(parent_node) = self.base().get_parent() {
            if let Ok(control) = parent_node.try_cast::<Control>() {
                control
            } else {
                godot_error!("Invalid parent node for Calculator - expected Control");
                return;
            }
        } else {
            godot_error!("Invalid parent node for Calculator - expected Control");
            return;
        };
        // Calculate data
        self.odata = algorithm(&mut self.idata);
        // Layout
        self.layout(&self.odata, parent);
        // Emit completion signal
        self.signals().calculator_prepared().emit();
    }

    #[signal]
    fn start_calculation();

    #[signal]
    fn calculator_prepared();
}

impl IData {
    fn initialize(path: &str) -> Self {
        let file = FileAccess::open(path, ModeFlags::READ)
            .ok_or("Failed to open save file")
            .unwrap();
        let content = file.get_as_text();

        let mut data = IData::new();
        match data.deserialize_gstring(&content) {
            Ok(_) => {}
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
