extends PopupPanel

func _ready():
	create_tree_items()
	
func create_tree_items() -> void:
	var tree = $"WindowTypeSetting/SelectTab/Third-Party License/Third-PartyVContainer/LicenseHSplit/LicenseTree"
	# tree.set_column_custom_minimum_width(0, 180)
	var root = tree.create_item()
	tree.hide_root = true
	var godot = tree.create_item(root)
	godot.set_text(0,"Godot")
	var serde = tree.create_item(root)
	serde.set_text(0,"Serde_Json")
	var tokio = tree.create_item(root)
	tokio.set_text(0,"Tokio")
