extends PopupPanel

var item_contents = [
	"Godot Engine\n\tFiles:\n\t\t*\n\t© 2014-present, Godot Engine contributors\n\t© 2007-2017, Juan Linietsky, Ariel Manzur\n\tLicense: Expat",
	"Serde_json\n\tFiles:\n\t\trust/src/serial.rs\n\t© 2015-present, Serde contributors\n\tLicense: MIT OR Apache-2.0",
	"Tokio\n\tFiles:\n\t\trust/src/driver.rs\n\t© 2016-present, Tokio-rs contributors\n\tLicense: MIT ",
]

func _on_license_itemlist_item_selected(index: int) -> void:
	var txt_label = $"WindowTypeSetting/SelectTab/Third-Party License/Third-PartyVContainer/LicenseHSplit/LicenseScroll/SpecificLicense"
	txt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	if index >= 0 and index < item_contents.size():
		txt_label.text = item_contents[index]
	else:
		push_error("No License found")


func _on_confirm_button_pressed() -> void:
	hide()
