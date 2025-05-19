extends Node

class_name Component

@export var node_id: int = -1
@export var node_name: String = ""
@export var node_type: String = ""
@export var reliability: float = 0.0
@export var prev_node: Array[int]

func printall() -> void:
    print_rich("[color=pink]&&&&&[/color] node_id: %s || node_name: %s || node_type: %s || reliability: %s || prev_node: %s [color=pink]&&&&&[/color]" % [node_id, node_name, node_type, reliability, prev_node])