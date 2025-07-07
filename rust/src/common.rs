use rand_distr::{Cauchy, Distribution, Normal};
use rand::rng;

pub fn generate_rand(turns: u16) -> Vec<Vec<f64>>{
    let mut rng = rng();
    let mut v = Vec::new();
    for _ in 0..turns{
        // Vertex A
        let normal = Normal::new(480., 1.).unwrap();
        let cauchy = Cauchy::new(286., 2.).unwrap();
        let pair = vec![normal.sample(&mut rng), cauchy.sample(&mut rng)];
        v.push(pair);
        // Vertex B
        let normal = Normal::new(1305., 1.).unwrap();
        let pair = vec![normal.sample(&mut rng), cauchy.sample(&mut rng)];
        v.push(pair);
        // Vertex C
        let cauchy = Cauchy::new(744., 2.).unwrap();
        let pair = vec![normal.sample(&mut rng), cauchy.sample(&mut rng)];
        v.push(pair);
        // Vertex D
        let normal = Normal::new(480., 1.).unwrap();
        let pair = vec![normal.sample(&mut rng), cauchy.sample(&mut rng)];
        v.push(pair);
    }
    return v
}

#[allow(dead_code)]
pub fn print_rand_data(data: &Vec<Vec<f64>>) {
    for (i, row) in data.iter().enumerate() {
        print!("Row {}: [", i);
        for (j, val) in row.iter().enumerate() {
            if j != 0 {
                print!(", ");
            }
            print!("{:.4}", val);
        }
        println!("]");
    }
}