use godot::prelude::*;
use godot::classes::LabelSettings;

#[allow(dead_code)]
pub fn get_header_labelsettings() -> Gd<LabelSettings> {
    let mut labelsettings = LabelSettings::new_gd();
    labelsettings.set_font_size(30);
    labelsettings.set_font_color(Color::BLACK);
    return labelsettings;
}