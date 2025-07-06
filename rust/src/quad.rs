use godot::classes::Line2D;
use godot::obj::WithBaseField;
use godot::prelude::*;
use rand_distr::{Cauchy, Distribution, Normal};
use rand::rng;

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
        let mut vertexs = generate_rand();
        loop {
            self.base_mut().add_point(vertexs.pop().unwrap());
            if vertexs.len() == 0 {
                break;
            }
        }
    }
}

fn generate_rand() -> Array<Vector2> {
    let mut rng = rng();
    // Vertex A
    let normal = Normal::new(480., 1.).unwrap();
    let cauchy = Cauchy::new(286., 2.).unwrap();
    let a = Vector2::new(normal.sample(&mut rng), cauchy.sample(&mut rng));
    // Vertex B
    let normal = Normal::new(1305., 1.).unwrap();
    let b = Vector2::new(normal.sample(&mut rng), cauchy.sample(&mut rng));
    // Vertex C
    let cauchy = Cauchy::new(744., 2.).unwrap();
    let c = Vector2::new(normal.sample(&mut rng), cauchy.sample(&mut rng));
    // Vertex D
    let normal = Normal::new(480., 1.).unwrap();
    let d = Vector2::new(normal.sample(&mut rng), cauchy.sample(&mut rng));
    // Assemble
    let mut arr = Array::new();
    arr.push(a);
    arr.push(b);
    arr.push(c);
    arr.push(d);
    return arr
}