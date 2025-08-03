use crate::model::EtaPath;
use crate::calc::Calculator;
use crate::model::OData;
use godot::classes::control::SizeFlags;
use godot::prelude::*;
use godot::classes::{Control, VBoxContainer, HBoxContainer, Label, ColorRect};
use std::collections::HashMap;

impl Calculator {
    pub fn layout(&self, odata: &OData, mut parent: Gd<Control>) {
        // Get parent node to ensure secure access
        // let parent = unsafe { parent.assume_safe() };
        
        // Create main `VBoxContainer`
        let mut vbox = VBoxContainer::new_alloc();
        vbox.set_name("EventTreeContainer");
        vbox.set_custom_minimum_size(Vector2::new(800.0, 600.0));
        // parent.add_child(vbox.clone().upcast());
        parent.add_child(&vbox);
        
        // let vbox = unsafe { vbox.assume_safe() };
        
        // Create header raw
        Self::create_header_row(&mut vbox);
        
        // Process all paths
        for (index, path) in odata.etapaths.iter().enumerate() {
            Self::create_path_row(&mut vbox, path, index);
        }
    }
    
    fn create_header_row(vbox: &mut Gd<VBoxContainer>) {
        // Create header `HBoxConatiner`
        let mut header_hbox = HBoxContainer::new_alloc();
        header_hbox.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // vbox.add_child(header_hbox.clone().upcast(), false);
        vbox.add_child(&header_hbox);
        
        // let header_hbox = unsafe { header_hbox.assume_safe() };
        
        // Probability Header
        let mut prob_header = Label::new_alloc();
        prob_header.set_text("Probability");
        prob_header.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // header_hbox.add_child(prob_header.upcast(), false);
        header_hbox.add_child(&prob_header);
        
        // Impact Header
        let mut impact_header = Label::new_alloc();
        impact_header.set_text("Impact");
        impact_header.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // header_hbox.add_child(impact_header.upcast(), false);
        header_hbox.add_child(&impact_header);
        
        // Event States Header
        let mut events_header = Label::new_alloc();
        events_header.set_text("Event States");
        events_header.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // header_hbox.add_child(events_header.upcast(), false);
        header_hbox.add_child(&events_header);
    }
    
    fn create_path_row(vbox: &mut Gd<VBoxContainer>, path: &EtaPath, index: usize) {
        // PathRow Header
        let mut hbox = HBoxContainer::new_alloc();
        hbox.set_name(&format!("PathRow_{}", index));
        hbox.set_h_size_flags(SizeFlags::EXPAND_FILL);
        
        // Override background colors
        if index % 2 == 0 {
            hbox.add_theme_color_override("background_color", Color::from_rgb(0.2, 0.2, 0.25));
        }
        
        // vbox.add_child(hbox.clone().upcast(), false);
        vbox.add_child(&hbox);
        // let hbox = unsafe { hbox.assume_safe() };
        
        // Add Probability label
        let mut prob_label = Label::new_alloc();
        prob_label.set_text(&format!("{:.4}", path.get_prob()));
        prob_label.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // hbox.add_child(prob_label.upcast(), false);
        hbox.add_child(&prob_label);
        
        // Visualize impact
        Self::add_impact_visual(&mut hbox, path.get_impact());
        
        // Add Event States label
        Self::add_event_states(&mut hbox, &path.get_path());
    }
    
    fn add_impact_visual(hbox: &mut Gd<HBoxContainer>, impact: f64) {
        // Create Impact `HBoxContainer`
        let mut impact_container = HBoxContainer::new_alloc();
        impact_container.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // hbox.add_child(impact_container.clone().upcast(), false);
        hbox.add_child(&impact_container);
        // let impact_container = unsafe { impact_container.assume_safe() };
        
        // Color indicator
        let mut color_rect = ColorRect::new_alloc();
        color_rect.set_custom_minimum_size(Vector2::new(20.0, 20.0));
        color_rect.set_color(Color::from_rgb(
            impact as f32, 
            1.0 - impact as f32, 
            0.0
        ));
        // impact_container.add_child(color_rect.upcast(), false);
        impact_container.add_child(&color_rect);
        
        // Add Impact Label
        let mut impact_label = Label::new_alloc();
        impact_label.set_text(&format!("{:.2}", impact));
        impact_label.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // impact_container.add_child(impact_label.upcast(), false);
        impact_container.add_child(&impact_label);
    }
    
    fn add_event_states(hbox: &mut Gd<HBoxContainer>, events: &HashMap<String, bool>) {
        // Create Events states `VBoxContainer`
        let mut events_container = VBoxContainer::new_alloc();
        events_container.set_h_size_flags(SizeFlags::EXPAND_FILL);
        // hbox.add_child(events_container.clone().upcast(), false);
        hbox.add_child(&events_container);
        // let events_container = unsafe { events_container.assume_safe() };
        
        // Sort Event names (to ensure consistent display order)
        let mut sorted_events: Vec<_> = events.iter().collect();
        sorted_events.sort_by_key(|(name, _)| &**name);
        
        // Add Events States label
        for (event, state) in sorted_events {
            let mut event_label = Label::new_alloc();
            let state_icon = if *state { "✓" } else { "✗" };
            event_label.set_text(&format!("{}: {}", event, state_icon));
            event_label.set_h_size_flags(SizeFlags::EXPAND_FILL);
            // events_container.add_child(event_label.upcast(), false);
            events_container.add_child(&event_label);
        }
    }
}
