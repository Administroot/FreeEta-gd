use crate::calc::Calculator;
use godot::prelude::*;
use godot::classes::{Control, HBoxContainer};
use godot::classes::control::LayoutPreset;

impl Calculator {
    pub fn layout(&self, mut parent: Gd<Control>) {
        // Get stages
        let stages = self.idata.get_stages_bfs();
        for stage in stages{
            godot_print!("Stage is {}", &stage);
        }
        // Create main container
        let mut main_container = HBoxContainer::new_alloc();
        main_container.set_name("EventTreeContainer");
        main_container.set_anchors_preset(LayoutPreset::FULL_RECT);
        parent.add_child(&main_container);
    }
}
