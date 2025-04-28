extends Node

class_name NodeTypes
	
@export var types: Array[NodeType] = []

func add_type(type: NodeType) -> void:
	types.append(type)

func get_type(index: int) -> NodeType:
	return types[index]

func get_type_by_name(node_name: String) -> NodeType:
	for index in range(len(types)):
		if types[index].node_name == node_name:
			return types[index]
	return null
