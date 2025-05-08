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

func print_all_members(nodetypes_name: String) -> void:
	LogUtil.info("-".repeat(50))
	LogUtil.info("%s includes:" % nodetypes_name)
	for type in types:
		print_rich("[color=orange]&&&&&[/color] node_name: %s || sprite_path: %s || short_desc: %s || long_desc: %s [color=orange]&&&&&[/color]" % [type.node_name, type.sprite_path, type.short_desc, type.long_desc])
	LogUtil.info("-".repeat(50))
