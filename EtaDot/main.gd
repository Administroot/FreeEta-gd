extends Node

@export var CommonNode: PackedScene

func _input(event):
	if event.is_action_pressed("ui_left"):
		var new_node = CommonNode.instantiate()
		new_node.position = get_viewport().get_mouse_position()
		add_child(new_node)
