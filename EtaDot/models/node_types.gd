extends Node

class_name NodeTypes
	
@export var types: Array[NodeType] = []

func add_type(type: NodeType) -> void:
	types.append(type)

func get_type(index: int) -> NodeType:
	return types[index]

func get_type_by_name(type_name: String) -> NodeType:
	for index in range(len(types)):
		if types[index].type_name == type_name:
			return types[index]
	return null

func print_all_members(nodetypes_name: String) -> void:
	LogUtil.info("-".repeat(50))
	LogUtil.info("%s includes:" % nodetypes_name)
	for type in types:
		type.print_all_members()
	LogUtil.info("-".repeat(50))
