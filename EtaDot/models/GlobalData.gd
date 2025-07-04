extends Node

var global_logger: String = ""
var error_logger: String = ""


func reload() -> void:
	components_data = get_components()
	reorganize_ending_comp()
	nodetypes_data = get_nodetypes()

#region Components
var components_data: Components
var selected_components := Components.new()

## JSON Serialize
func get_components() -> Components:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components, "user://saves/components.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]Components[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data

func save_components() -> void:
	# Calculate `Ending` component status
	reorganize_ending_comp()
	var json_data = JsonClassConverter.class_to_json(components_data)
	# Serialize
	components_data.print_all_members("Components")
	var file_success: bool = JsonClassConverter.store_json_file("user://saves/components.json", json_data)
	if !file_success:
		LogUtil.error("Error saving [color=golden]Components[/color] data.")

func reorganize_ending_comp() -> void:
	var orphans = components_data.get_all_component_ids()
	for comp in components_data.components:
		if comp.node_id == -1:
			continue
		for prev in comp.prev_node:
			if prev in orphans:
				orphans.erase(prev)
	# Erase self
	orphans.erase(-1)
	var ending_comp = Component.new()
	ending_comp.node_id = -1
	ending_comp.node_name = "Ending"
	ending_comp.node_type = "Initial"
	ending_comp.reliability = 1.
	ending_comp.prev_node = PackedInt64Array()
	for elem in orphans:
		ending_comp.prev_node.append(elem)
	ending_comp.printall()
	append_ending_comp(ending_comp)

# Fix Bug: When `ending_comp` doesn't at bottom of `components_data`, program will crash
func append_ending_comp(component: Component) -> void:
	for index in range(len(components_data.components)):
		if components_data.components[index].node_id == component.node_id:
			# Erase old node
			components_data.components.pop_at(index)
			break
	components_data.add_component(component)

#region NodeTypes
var nodetypes_data: NodeTypes

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

#region Recent
var recently_created_component_types: Array[NodeType] = []

func push_recent_component_type(nodetype: NodeType) -> void:
	if recently_created_component_types.size() <= 10:
		recently_created_component_types.push_front(nodetype)
	else:
		recently_created_component_types.pop_back()
#endregion

#region Testify
func print_global_data() -> void:
	components_data.print_all_members("@Global: Components Data: ")
	nodetypes_data.print_all_members("@Global: NodeTypes Data: ")

func print_recent_component_type() -> void:
	LogUtil.info("@Global: recently_created_component_types:")
	for member in recently_created_component_types:
		print(member.type_name)
	LogUtil.info("------------------------------------------")
#endregion
