use crate::model::System;

pub fn algorithm<'a>(sys: &'a mut System){
    let _ = sys.components;
    println!("I got system!");
}