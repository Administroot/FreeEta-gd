use godot::classes::Line2D;
use godot::obj::WithBaseField;
use godot::prelude::*;
use crate::common::generate_rand;

#[derive(GodotClass)]
#[class(base=Line2D)]
#[allow(dead_code)]
struct Quad {
    msg: String,
    base: Base<Line2D>,
}

use godot::classes::ILine2D;

#[godot_api]
impl ILine2D for Quad {
    fn init(base: Base<Line2D>) -> Self {
        Self { msg: "".to_string(), base }
    }

    fn ready(&mut self) {
        self.base_mut().set_closed(true);
        self.base_mut().set_default_color(Color { r: 30., g: 80., b: 162., a: 1. });

        // Generate vertexs
        self.generate_vertexs();
    }
}

#[godot_api]
impl Quad {
    #[func]
    fn generate_vertexs(&mut self){
        let mut vertexs = Self::assemble_vertexs(generate_rand(1u16));
        loop {
            self.base_mut().add_point(vertexs.pop().unwrap());
            if vertexs.len() == 0 {
                break;
            }
        }
    }
}

impl Quad {
    fn assemble_vertexs(mut raw_data: Vec<Vec<f64>>) -> Array<Vector2>{
        let mut v = Array::new();
        for _ in 0..raw_data.len(){
            let coordinate = raw_data.pop().unwrap();
            v.push(Vector2::new(coordinate[0] as f32, coordinate[1] as f32));
        }
        return v
    }
}