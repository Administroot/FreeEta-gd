use std::collections::HashMap;
use crate::model::{IData, OData};

// Identify high-risk paths ( probability > threshold )
// fn high_risk_paths(paths: &[(Vec<String>, f64, f64)], prob_threshold: f64) -> Vec<&(Vec<String>, f64, f64)> {
//     paths.iter()
//         .filter(|(_, prob, impact)| *prob > prob_threshold && *impact > 0.5)
//         .collect()
// }

fn parse_path_to_odatas(paths: &[(Vec<String>, f64, f64)]) -> Vec<OData> {
    let mut odatas = Vec::new();
    for (path, prob, impact) in paths {
        let mut map = HashMap::new();
        for pair in path{
            let parts: Vec<&str> = pair.split(':').collect();
            if parts.len() == 2 {
                let key = parts[0].to_string();
                let value = match parts[1] {
                    "Success" => true,
                    "Failure" => false,
                    _ => false,
                };
                map.insert(key, value);
            }
        }
        odatas.push(OData::new(map, *prob, *impact));
    }
    odatas
}

pub fn algorithm<'a>(idata: &'a mut IData){
    let eta = idata.to_etanode();
    // Generate all paths
    let paths = eta.generate_paths();
    println!("All Paths:");
    for (path, prob, impact) in &paths {
        println!("- Path: {:?}, Prob: {:.4}, Impact: {:.2}", path, prob, impact);
    }
    parse_path_to_odatas(&paths);
}