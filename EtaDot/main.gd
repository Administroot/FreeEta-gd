extends Node

@onready var components_data = get_components()

#region Boot Up
func _init() -> void:
	var dir = DirAccess.open("user://saves")
	if dir == null:
		DirAccess.make_dir_absolute("user://saves")
	check_saves("node_types.json")
	check_saves("components.json")

func check_saves(saves_name: String) -> void:
	if not FileAccess.file_exists("user://saves/" + saves_name):
		var source = FileAccess.open("res://examples/saves/" + saves_name, FileAccess.READ)
		var target = FileAccess.open("user://saves/" + saves_name, FileAccess.WRITE)
		target.store_string(source.get_as_text())
		source.close()
		target.close()
#endregion

#region CustomNodes
func _ready() -> void:
	# Connect signals from scene `BottomSlide`
	$"Scenes/BottomSlide".view_button_toggled.connect(on_view_button_toggled)
	$"Scenes/BottomSlide".eta_button_toggled.connect(on_eta_button_toggled)
	$"Scenes/BottomSlide".code_button_toggled.connect(on_code_button_toggled)
#endregion

#region View
func on_view_button_toggled() -> void:
	components_data.print_all_members("View")
	create_components()
	# for i in range(len(components_data.components)):
	# 	create_components(i)
		# var new_node = load("res://component.tscn").instantiate()
		# new_node.position = get_viewport().get_mouse_position()
		# add_child(new_node)

const X_SPACING := 120
const Y_SPACING := 80

# Assume：
# `ComponentMarker` as a anchor of root node
# `component.tscn` as node `Component` prefab
# `TreeBranch.tscn` as `Line` prefab
# `components_data` has loaded

# Recursive constructing tree structure
func build_tree_structure() -> Dictionary:
	var id_to_node = {}
	var roots = []
	# Build node map
	for comp in components_data.components:
		id_to_node[comp.node_id] = {
			"component": comp,
			"children": []
		}
	# Establish parent relationship
	for comp in components_data.components:
		for prev in comp.prev_node:
			if prev != -1 and id_to_node.has(prev):
				id_to_node[prev]["children"].append(id_to_node[comp.node_id])
	# Find all root nodes
	for comp in components_data.components:
		if comp.prev_node.size() == 0 or comp.prev_node[0] == -1:
			roots.append(id_to_node[comp.node_id])
	return {"roots": roots, "id_to_node": id_to_node}

# Recursively calculating `width` of each `Component`
func get_max_child_num(node: Dictionary) -> int:
	if node["children"].size() == 0:
		return 1
	var num = 0
	for child in node["children"]:
		num += get_max_child_num(child)
	return num

# Draw tree recursively
func draw_tree(node: Dictionary, position: Vector2, parent_marker: Node = null) -> Node:
	# Initialize `Component` nodes
	var comp_scene = load("res://component.tscn")
	var comp_node = comp_scene.instantiate()
	comp_node.position = position
	$CustomNodes.add_child(comp_node)
	# Set node info (Optional)
	# comp_node.set_component_info(node["component"])
	# Draw line
	if parent_marker:
		draw_tree_branch(parent_marker, comp_node)
	# Draw child nodes recursively
	if node["children"].size() == 0:
		return comp_node
	var width = get_max_child_num(node)
	var width_size = width * Y_SPACING
	var size_start = - width_size / 2.0
	for child in node["children"]:
		var child_width = get_max_child_num(child)
		var rate = max(child_width, 1) / width
		size_start += rate * width_size / 2
		var child_pos = position + Vector2(X_SPACING, size_start)
		draw_tree(child, child_pos, comp_node)
		size_start += rate * width_size / 2
	return comp_node
		
# Draw line (Optional: `TreeBranch.tscn` exists)
func draw_tree_branch(a: Node, b: Node) -> void:
	if not ResourceLoader.exists("res://TreeBranch.tscn"):
		return
	var branch_scene = load("res://TreeBranch.tscn")
	var branch = branch_scene.instantiate()
	add_child(branch)
	# If $"Line2D" exists
	var line = branch.get_node("Line2D")
	line.clear_points()
	line.add_point(a.position)
	line.add_point(b.position)

# Main Entrance
func create_components() -> void:
	# Clean old components.
	for child in $CustomNodes.get_children():
		# TODO: Delete old tree
		if child.name.begins_with("ComponentInstance"):
			remove_child(child)
			child.queue_free()
	# Build tree structure
	var tree = build_tree_structure()
	LogUtil.info("Tree: %s" % tree)
	var marker = $CustomNodes/ComponentMarker
	var root_pos = marker.position
	# Draw all root positions
	for root in tree["roots"]:
		draw_tree(root, root_pos)


# func create_components(index: int) -> void:
# 	# Relocate `Marker`
# 	var marker = $CustomNodes/ComponentMarker
# 	if index:
# 		var recent = components_data.get_component(index)
# 		var prev = components_data.get_component(index - 1)
# 		# TODO: Improve locate logic. When `Apposition` situation, 
# 		if recent.prev_node[0] != prev.node_id:
# 			# Apposition
# 			marker.position = Vector2(marker.position.x, marker.position.y)
# 			LogUtil.info("marker.position=%s" % marker.position)
# 		else :
# 			# Parent
# 			marker.position = marker.position + Vector2(100, 0)
# 	# Visualize a component
	

#JSON Serialize and Deserialize
func get_components() -> Components:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components, "user://saves/components.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]Components[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data
#endregion

#region ETA
func on_eta_button_toggled() -> void:
	components_data.print_all_members("Components")
	LogUtil.info("ETA button toggled")
#endregion

#region Code
func on_code_button_toggled() -> void:
	LogUtil.info("Code button toggled")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var new_node = load("res://component.tscn").instantiate()
		new_node.position = get_viewport().get_mouse_position()
		add_child(new_node)
#endregion
