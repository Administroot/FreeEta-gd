extends Tree


func _ready() -> void:
	var root = create_item()
	create_label(root, "Pop")
	create_label(root, "Valve")
	
func create_label(parent: TreeItem, label_name: String, path: String = "res://assets/ellipsis.svg") -> void:
	var label = create_item(parent)
	label.set_text(0, label_name)
	label.set_custom_font_size(0, 25)
	label.add_button(0, load(path), -1, false, "")
	label.set_editable(0, true)
