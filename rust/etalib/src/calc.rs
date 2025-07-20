use godot::classes::{file_access::ModeFlags, Node};
use godot::prelude::*;
use crate::model::{IData, deserialize_system_from_path};

#[derive(GodotClass)]
#[class(base=Node)]
struct Calculator {
    sys: IData,
    base: Base<Node>,
}

use godot::classes::{INode, FileAccess};
use std::fs;
use std::path::PathBuf;

#[godot_api]
impl INode for Calculator {
    fn init(base: Base<Node>) -> Self {
        Self { sys: IData::new(), base}
    }

    fn ready(&mut self) {
        match load_system(Some("user://saves/components.json")){
            Ok(res) => {
                self.sys = res;
            },
            Err(e) => {
                godot_error!("{}", e);
            }
        }
        self.generate_eta_data();
    }
}

#[godot_api]
impl Calculator {
    #[func]
    fn generate_eta_data(&mut self){
        let _ = self;
        godot_print!("I have got system!");
    }
}

fn load_system(path: Option<&str>) -> Result<IData, Box<dyn std::error::Error>> {
    let path = path.unwrap_or("user://saves/components.json");
    let file = FileAccess::open(path, ModeFlags::READ)
        .ok_or("Failed to open save file")?;
    let content = file.get_as_text();
    // Write the contents to a temporary file so we can use deserialize_system_from_path
    let tmp_path = PathBuf::from(&format!("tmp_{}" , &path));
    fs::write(&tmp_path, content.to_string())?;
    let system = deserialize_system_from_path(&tmp_path)?;
    // Optionally, remove the temporary file
    let _ = fs::remove_file(&tmp_path);
    Ok(system)
}