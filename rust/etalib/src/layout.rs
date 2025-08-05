use crate::model::{ EtaPath, OData };
use crate::calc::Calculator;
use crate::theme::get_header_labelsettings;
use godot::prelude::*;
use godot::classes::{
    ColorRect, Control, HBoxContainer, Label, MarginContainer, Node, VBoxContainer
};
use godot::classes::control::LayoutPreset;
use godot::classes::control::SizeFlags;
use godot::global::HorizontalAlignment;
use std::collections::HashMap;

impl Calculator {
    pub fn layout(&self, odata: &OData, mut parent: Gd<Control>) {
        // Create main container
        let mut main_container = MarginContainer::new_alloc();
        main_container.set_name("EventTreeContainer");
        main_container.set_anchors_preset(LayoutPreset::FULL_RECT);
        parent.add_child(&main_container);

        // Create vertical layout container
        let mut vbox = VBoxContainer::new_alloc();
        vbox.set_v_size_flags(SizeFlags::EXPAND_FILL);
        main_container.add_child(&vbox);

        // Add header row
        self.create_header_row(&mut vbox);

        // Process all paths
        for (index, path) in odata.etapaths.iter().enumerate() {
            self.create_path_row(&mut vbox, path, index);
        }

        // Execute tree layout
        self.apply_tree_layout(&mut main_container);
    }

    fn create_header_row(&self, vbox: &mut Gd<VBoxContainer>) {
        let header_theme = get_header_labelsettings();

        let mut header = HBoxContainer::new_alloc();
        vbox.add_child(&header);

        // Prob Header
        let mut prob_header = Label::new_alloc();
        prob_header.set_label_settings(&header_theme);
        prob_header.set_text("Probability");
        prob_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&prob_header);

        // Impact Header
        let mut impact_header = Label::new_alloc();
        impact_header.set_label_settings(&header_theme);
        impact_header.set_text("Impact");
        impact_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&impact_header);

        // Events Header
        let mut events_header = Label::new_alloc();
        events_header.set_label_settings(&header_theme);
        events_header.set_text("Event States");
        events_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&events_header);
    }

    fn create_path_row(&self, vbox: &mut Gd<VBoxContainer>, path: &EtaPath, index: usize) {
        let header_theme = get_header_labelsettings();

        let mut hbox = HBoxContainer::new_alloc();
        hbox.set_name(&format!("PathRow_{}", index));
        vbox.add_child(&hbox);

        // Add Probability Label
        let mut prob_label = Label::new_alloc();
        prob_label.set_label_settings(&header_theme);
        prob_label.set_text(&format!("{:.4}", path.get_prob()));
        prob_label.add_theme_font_size_override("Hello", 30);
        prob_label.set_custom_minimum_size(Vector2::new(100.0, 0.0));
        hbox.add_child(&prob_label);

        // Visualize impact
        self.add_impact_visual(&mut hbox, path.get_impact());

        // Add event states label
        self.add_event_states(&mut hbox, &path.get_path());
    }

    fn add_impact_visual(&self, hbox: &mut Gd<HBoxContainer>, impact: f64) {

        let mut color_rect = ColorRect::new_alloc();
        color_rect.set_custom_minimum_size(Vector2::new(20.0, 20.0));

        // Set color according to the impact value
        // - red-high impact
        // - green-low impact
        color_rect.set_color(Color::from_rgb(impact as f32, 1.0 - (impact as f32), 0.0));

        hbox.add_child(&color_rect);

        // Add Impact Label
        let mut impact_label = Label::new_alloc();
        impact_label.set_text(&format!("{:.2}", impact));
        impact_label.set_custom_minimum_size(Vector2::new(50.0, 0.0));
        hbox.add_child(&impact_label);
    }

    fn add_event_states(&self, hbox: &mut Gd<HBoxContainer>, events: &HashMap<String, bool>) {
        let mut sorted_events: Vec<_> = events.iter().collect();
        sorted_events.sort_by_key(|(name, _)| &**name);

        let mut events_container = HBoxContainer::new_alloc();
        hbox.add_child(&events_container);

        for (event, state) in sorted_events {
            let mut event_label = Label::new_alloc();
            let state_icon = if *state { "✓" } else { "✗" };
            event_label.set_text(&format!("{}:{} ", event, state_icon));
            events_container.add_child(&event_label);
        }
    }

    fn apply_tree_layout(&self, container: &mut Gd<MarginContainer>) {
        // Get root node
        let root = match container.get_node_or_null("EventTreeRoot") {
            Some(node) => node,
            None => {
                godot_error!("Root node not found");
                return;
            }
        };

        // Initialize tree
        self.init_tree(root.clone());

        // Execute layout algorithm
        self.layout_tree(root);
    }

    fn init_tree(&self, mut node: Gd<Node>) {
        // Set node hierarchy
        let layer_value = Variant::from(0);
        node.set("layer", &layer_value);

        // Recursively initializing child nodes
        let children = node.get_children();
        for i in 0..children.len() {
            let mut child = children.get(i).unwrap();
            let layer_value = node.get("layer").to::<i32>() + 1;
            let layer_variant = Variant::from(layer_value);
            child.set("layer", &layer_variant);
            self.init_tree(child);
        }
    }

    fn layout_tree(&self, node: Gd<Node>) {
        let x_interval = 200.0;
        let y_interval = 50.0;

        // Layout children
        let children = node.get_children();
        for i in 0..children.len() {
            let mut child = children.get(i).unwrap();
            let index_variant = Variant::from(i as i64);
            child.set("in_parent_index", &index_variant);

            // Calculate position
            let parent_pos = node.get("position").to::<Vector2>();
            let child_x = parent_pos.x + x_interval;
            let child_y = parent_pos.y + (i as f32) * y_interval;

            let pos_variant = Variant::from(Vector2::new(child_x, child_y));
            child.set("position", &pos_variant);

            // Layout recursively
            self.layout_tree(child);
        }

        // Handle node overlaps
        self.resolve_overlaps(node);
    }

    fn resolve_overlaps(&self, node: Gd<Node>) {
        let children = node.get_children();
        for i in 0..children.len() {
            for j in i + 1..children.len() {
                let child1 = children.get(i).unwrap();
                let child2 = children.get(j).unwrap();

                if self.is_overlapping(child1, child2.clone()) {
                    // Adjust child position
                    let mut child2_mut = child2;
                    let pos = child2_mut.get("position").to::<Vector2>();
                    let new_y = pos.y + 60.0;
                    let new_pos_variant = Variant::from(Vector2::new(pos.x, new_y));
                    child2_mut.set("position", &new_pos_variant);
                }
            }
        }
    }

    fn is_overlapping(&self, node1: Gd<Node>, node2: Gd<Node>) -> bool {
        let pos1 = node1.get("position").to::<Vector2>();
        let pos2 = node2.get("position").to::<Vector2>();
        // let size = Vector2::new(200.0, 40.0); // TODO: Assumed node size
        let size = Vector2::new(400.0, 80.0);

        // Check for overlapping rectangles
        pos1.x < pos2.x + size.x &&
            pos1.x + size.x > pos2.x &&
            pos1.y < pos2.y + size.y &&
            pos1.y + size.y > pos2.y
    }
}
