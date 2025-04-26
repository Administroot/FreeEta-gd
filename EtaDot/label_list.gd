extends Tree

func _ready() -> void:
	var root = create_item()
	create_label(root, "red", "res://assets/redpoint.svg")
	create_label(root, "orange", "res://assets/orangepoint.svg")
	create_label(root, "yellow", "res://assets/yellowpoint.svg")
	create_label(root, "green", "res://assets/greenpoint.svg")
	create_label(root, "blue", "res://assets/bluepoint.svg")
	create_label(root, "purple", "res://assets/purplepoint.svg")
	create_label(root, "grey", "res://assets/greypoint.svg")
	
func create_label(parent: TreeItem, label_name: String, path: String) -> void:
	var label = create_item(parent)
	label.set_text(0, label_name)
	label.set_custom_font_size(0, 25)
	label.add_button(0, load(path), -1, false, "")
	label.set_editable(0, true)


func _on_item_edited() -> void:
	var treeitem = get_edited()
	if treeitem != null and treeitem.get_text(0) == "":
		treeitem.free()
