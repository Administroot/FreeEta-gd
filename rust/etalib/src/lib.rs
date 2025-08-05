use godot::prelude::*;

struct RustExtension;

#[gdextension]
unsafe impl ExtensionLibrary for RustExtension {}

mod calc;
mod layout;
mod theme;
pub mod common;
pub mod model;
