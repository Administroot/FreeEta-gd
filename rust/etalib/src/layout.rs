use crate::model::{EtaPath, OData};
use crate::calc::Calculator;
use godot::prelude::*;
use godot::classes::{Node, Control, VBoxContainer, HBoxContainer, Label, ColorRect, MarginContainer};
use godot::classes::control::LayoutPreset;
use godot::classes::control::SizeFlags;
use godot::global::HorizontalAlignment;
use std::collections::HashMap;

impl Calculator {
    pub fn layout(&self, odata: &OData, mut parent: Gd<Control>) {
        // 创建主容器
        let mut main_container = MarginContainer::new_alloc();
        main_container.set_name("EventTreeContainer");
        main_container.set_anchors_preset(LayoutPreset::FULL_RECT);
        parent.add_child(&main_container);

        // 创建垂直布局容器
        let mut vbox = VBoxContainer::new_alloc();
        vbox.set_v_size_flags(SizeFlags::EXPAND_FILL);
        main_container.add_child(&vbox);

        // 添加标题行
        self.create_header_row(&mut vbox);

        // 处理每条路径
        for (index, path) in odata.etapaths.iter().enumerate() {
            self.create_path_row(&mut vbox, path, index);
        }

        // 执行树形布局
        self.apply_tree_layout(&mut main_container);
    }

    fn create_header_row(&self, vbox: &mut Gd<VBoxContainer>) {
        let mut header = HBoxContainer::new_alloc();
        vbox.add_child(&header);

        // 概率标题
        let mut prob_header = Label::new_alloc();
        prob_header.set_text("Probability");
        prob_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&prob_header);

        // 影响值标题
        let mut impact_header = Label::new_alloc();
        impact_header.set_text("Impact");
        impact_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&impact_header);

        // 事件状态标题
        let mut events_header = Label::new_alloc();
        events_header.set_text("Event States");
        events_header.set_horizontal_alignment(HorizontalAlignment::CENTER);
        header.add_child(&events_header);
    }

    fn create_path_row(&self, vbox: &mut Gd<VBoxContainer>, path: &EtaPath, index: usize) {
        let mut hbox = HBoxContainer::new_alloc();
        hbox.set_name(&format!("PathRow_{}", index));
        vbox.add_child(&hbox);

        // 添加概率标签
        let mut prob_label = Label::new_alloc();
        prob_label.set_text(&format!("{:.4}", path.get_prob()));
        prob_label.set_custom_minimum_size(Vector2::new(100.0, 0.0));
        hbox.add_child(&prob_label);

        // 添加影响值可视化
        self.add_impact_visual(&mut hbox, path.get_impact());

        // 添加事件状态标签
        self.add_event_states(&mut hbox, &path.get_path());
    }

    fn add_impact_visual(&self, hbox: &mut Gd<HBoxContainer>, impact: f64) {
        let mut color_rect = ColorRect::new_alloc();
        color_rect.set_custom_minimum_size(Vector2::new(20.0, 20.0));
        
        // 根据影响值设置颜色（红-高影响，绿-低影响）
        color_rect.set_color(Color::from_rgb(
            impact as f32, 
            1.0 - impact as f32, 
            0.0
        ));
        
        hbox.add_child(&color_rect);
        
        // 添加数值标签
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
        // 获取根节点
        let root = match container.get_node_or_null("EventTreeRoot") {
            Some(node) => node,
            None => {
                godot_error!("Root node not found");
                return;
            }
        };
        
        // 初始化树结构
        self.init_tree(root.clone());
        
        // 执行布局算法
        self.layout_tree(root);
    }

    fn init_tree(&self, mut node: Gd<Node>) {
        // 设置节点层级
        let layer_value = Variant::from(0);
        node.set("layer", &layer_value);
        
        // 递归初始化子节点
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
        // 实现树形布局算法（基于用户提供的GDScript逻辑）
        let x_interval = 200.0;
        let y_interval = 50.0;
        
        // 布局子节点
        let children = node.get_children();
        for i in 0..children.len() {
            let mut child = children.get(i).unwrap();
            let index_variant = Variant::from(i as i64);
            child.set("in_parent_index", &index_variant);
            
            // 计算位置
            let parent_pos = node.get("position").to::<Vector2>();
            let child_x = parent_pos.x + x_interval;
            let child_y = parent_pos.y + (i as f32) * y_interval;
            
            let pos_variant = Variant::from(Vector2::new(child_x, child_y));
            child.set("position", &pos_variant);
            
            // 递归布局
            self.layout_tree(child);
        }
        
        // 处理节点重叠
        self.resolve_overlaps(node);
    }

    fn resolve_overlaps(&self, node: Gd<Node>) {
        // 基于用户提供的GDScript重叠解决方案
        let children = node.get_children();
        for i in 0..children.len() {
            for j in (i + 1)..children.len() {
                let child1 = children.get(i).unwrap();
                let child2 = children.get(j).unwrap();
                
                if self.is_overlapping(child1, child2.clone()) {
                    // 调整位置解决重叠
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
        let size = Vector2::new(200.0, 40.0); // 假设节点大小
        
        // 检查矩形重叠
        pos1.x < pos2.x + size.x &&
        pos1.x + size.x > pos2.x &&
        pos1.y < pos2.y + size.y &&
        pos1.y + size.y > pos2.y
    }
}
