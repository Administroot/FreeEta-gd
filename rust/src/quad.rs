use godot::classes::Line2D;
use godot::obj::WithBaseField;
use godot::prelude::*;

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
        godot_print!("This is a quadrilateral!");

        Self { msg: "".to_string(), base }
    }

    fn ready(&mut self) {
        self.base_mut().set_closed(true);
        self.base_mut().set_default_color(Color { r: 30., g: 80., b: 162., a: 1. });

        // Generate vertexs
        let a = Vector2::new(525., 297.);
        let b = Vector2::new(1488., 286.);
        let c = Vector2::new(1488., 811.);
        let d = Vector2::new(514., 817.);
        self.base_mut().add_point(a);
        self.base_mut().add_point(b);
        self.base_mut().add_point(c);
        self.base_mut().add_point(d);
    }
}