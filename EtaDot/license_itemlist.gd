extends ItemList

func _ready() -> void:
	create_items()
	
func create_items() -> void:
	add_item("Godot")
	add_item("Serde_json")
	add_item("Tokio")
