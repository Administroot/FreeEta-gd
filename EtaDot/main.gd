extends Node

func _init() -> void:
	var dir = DirAccess.open("user://config")
	if dir == null:
		DirAccess.make_dir_absolute("user://config")
	check_config("node_types.json")
	check_config("components.json")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var new_node = load("res://component.tscn").instantiate()
		new_node.position = get_viewport().get_mouse_position()
		add_child(new_node)

func check_config(config_name: String) -> void:
	if not FileAccess.file_exists("user://config/" + config_name):
		var source = FileAccess.open("res://examples/config/" + config_name, FileAccess.READ)
		var target = FileAccess.open("user://config/" + config_name, FileAccess.WRITE)
		target.store_string(source.get_as_text())
		source.close()
		target.close()