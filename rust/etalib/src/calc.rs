use godot::classes::{file_access::ModeFlags, Node};
use godot::prelude::*;
use crate::model::IData;

#[derive(GodotClass)]
#[class(base=Node)]
#[allow(dead_code)]
struct Calculator {
    idata: IData,
    base: Base<Node>,
}

use godot::classes::{INode, FileAccess};
use std::fs;
use std::path::PathBuf;

#[godot_api]
impl INode for Calculator {
    fn init(base: Base<Node>) -> Self {
        Self { idata: IData::new("user://saves/components.json"), base }
    }
}

#[godot_api]
impl Calculator {
    #[func]
    fn generate_eta_data(&mut self){
        // TODO:
        let _ = self;
        godot_print!("I have got system!");
    }
}

impl IData {
    pub fn new(path: &str) -> Self {
        let file = FileAccess::open(path, ModeFlags::READ)
            .ok_or("Failed to open save file").unwrap();
        let content = file.get_as_text();
        // Write the contents to a temporary file so we can use deserialize_system_from_path
        let tmp_path = PathBuf::from(&format!("tmp_{}" , &path));
        fs::write(&tmp_path, content.to_string()).expect(&format!("Cannnot write buffer to {}", tmp_path.display()));
        // Optionally, remove the temporary file
        let _ = fs::remove_file(&tmp_path);
        let mut data = IData {components: vec![]};
        match data.deserialize(&tmp_path) {
            Ok(_) => {},
            Err(e) => godot_error!("Deserialize stage failed: {}", e),
        }
        data
    }
}