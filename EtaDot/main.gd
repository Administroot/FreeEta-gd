extends Node

func _ready() -> void:
	var dir = DirAccess.open("user://config")
	if dir == null:
		DirAccess.make_dir_absolute("user://config")
	
	if not FileAccess.file_exists("user://config/node_types.json"):
		var source = FileAccess.open("res://examples/config/node_types.json", FileAccess.READ)
		var target = FileAccess.open("user://config/node_types.json", FileAccess.WRITE)
		target.store_string(source.get_as_text())
		source.close()
		target.close()

func _input(event):
	if event.is_action_pressed("ui_left"):
		var new_node = load("res://common_node.tscn").instantiate()
		new_node.position = get_viewport().get_mouse_position()
		add_child(new_node)
