use crate::model::System;

pub fn algorithm<'a>(sys: &'a mut System){
    let eta = sys.system_to_etanode();
    // Generate all paths
    let paths = eta.generate_paths();
    println!("All Paths:");
    for (path, prob, impact) in &paths {
        println!("- Path: {:?}, Prob: {:.4}, Impact: {:.2}", path, prob, impact);
    }
}