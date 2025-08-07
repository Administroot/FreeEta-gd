use crate::calc::Calculator;
use crate::theme::get_header_labelsettings;
use godot::prelude::*;
use godot::classes::{Control, HBoxContainer, Label};
use godot::classes::control::{LayoutPreset, SizeFlags};

impl Calculator {
    pub fn layout(&self, mut parent: Gd<Control>) {
        // Themes
        let header_label_setting = get_header_labelsettings();

        // Get stages
        let stages = self.idata.get_stages_bfs();

        // Create main container
        let mut main_container = HBoxContainer::new_alloc();
        main_container.set_name("EventHeaderContainer");
        main_container.set_anchors_preset(LayoutPreset::FULL_RECT);
        parent.add_child(&main_container);

        // Create headers
        for stage in stages {
            let mut header_label = Label::new_alloc();
            header_label.set_name(&stage);
            header_label.set_text(&stage);
            header_label.set_label_settings(&header_label_setting);
            header_label.set_h_size_flags(SizeFlags::EXPAND_FILL);
            main_container.add_child(&header_label);
        }
    }
}
