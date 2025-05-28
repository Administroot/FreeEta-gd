extends Node

#region Components
var components_data: Components

## JSON Serialize
func get_components() -> Components:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components, "user://saves/components.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]Components[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data

func save_components() -> void:
	var json_data = JsonClassConverter.class_to_json(components_data)
	# Serialize
	components_data.print_all_members("Components")
	var file_success: bool = JsonClassConverter.store_json_file("user://saves/components.json", json_data)
	if !file_success:
		LogUtil.error("Error saving [color=golden]Components[/color] data.")

#region NodeTypes
var nodetypes_data : NodeTypes

#JSON Serialize and Deserialize
func get_nodetypes() -> NodeTypes:
	var loaded_data: NodeTypes = JsonClassConverter.json_file_to_class(NodeTypes, "user://saves/node_types.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]NodeType[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data

## Serialize `NodeType` and save into file.
## Params:
##	`nodetype`(NodeType): The nodetype you want to update or add.
##	`savemode`(bool): `false` for Update, `true` for Add.
func save_nodetypes(nodetype: NodeType, savemode: bool, node_id: int = 0) -> void:
	if savemode:
		# Add mode
		nodetypes_data.add_type(nodetype)
	else:
		# Update mode
		nodetypes_data.types[node_id] = nodetype
	# Serialize
	nodetypes_data.print_all_members("NodeTypes")
	var json_data = JsonClassConverter.class_to_json(nodetypes_data)
	var file_success: bool = JsonClassConverter.store_json_file("user://saves/node_types.json", json_data)
	if !file_success:
		LogUtil.error("Error saving [color=golden]NodeType[/color] data.")
#endregion

#region Testify
func print_global_data() -> void:
	components_data.print_all_members("@Global: Components Data: ")
	nodetypes_data.print_all_members("@Global: NodeTypes Data: ")
#endregion
