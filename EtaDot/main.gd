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

# Adjacency list algorithm
func create_adjacency_list() -> Dictionary:
	var component_graph = {}
	# Initialize graph with basic component info
	for comp in components_data.components:
		component_graph[comp.node_id
] = {
	"name": comp.node_name,
	"type": comp.node_type,
	"reliability": comp.reliability,
	"prev": comp.prev_node,
	"next": [] # Will be populated below
}
	# Populate the next nodes list
	for comp in components_data.components:
		# For each node that has this as prev, add this node to their prev's next list
		for prev_id in comp.prev_node:
			if prev_id != -1 and prev_id in component_graph:
				component_graph[prev_id
][
	"next"
].append(comp.node_id)
	return component_graph

const MIN_X_SPACING := 100
const MAX_Y_SPACING := 40

# Main Entrance
# TODO: Test more datasets
func create_components() -> void:
	var graph = create_adjacency_list()
	print_adjacency_list(graph)
	
	# Start from root nodes (nodes with empty prev)
	var root_nodes = find_root_nodes(graph)
	var pos = Vector2(100, 300)  # Starting position
	
	# Create and position nodes using recursive traversal
	for root in root_nodes:
		visualize_node(root, graph, pos, {})

func find_root_nodes(graph: Dictionary) -> Array:
	var roots = []
	for node_id in graph:
		if graph[node_id]["prev"].is_empty():
			roots.append(node_id)
	return roots

func visualize_node(node_id: int, graph: Dictionary, pos: Vector2, visited: Dictionary) -> void:
	if node_id in visited:
		return
		
	visited[node_id] = true
	
	# Create component node
	var new_node = load("res://component.tscn").instantiate()
	new_node.position = pos
	add_child(new_node)
	
	# Calculate positions for child nodes
	var next_nodes = graph[node_id]["next"]
	
	# Calculate vertical offset based on number of parallel components
	var total_height = (len(next_nodes) - 1) * MAX_Y_SPACING
	var start_y = pos.y - (total_height / 2.)  # Center the parallel components
	
	for i in range(len(next_nodes)):
		var next_id = next_nodes[i]
		var new_node_size = new_node.size
		var next_pos = Vector2(
			pos.x + MIN_X_SPACING + new_node_size.x, 
			start_y + (i * MAX_Y_SPACING)
		)
		
		visualize_node(next_id, graph, next_pos, visited)

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

#region Debugging
func print_adjacency_list(dict: Dictionary) -> String:
	var output = "Component Graph Structure:\n"
	for node_id in dict:
		var node = dict[node_id]
		var prev_str = str(node["prev"]).replace(" ", "")
		var next_str = str(node["next"]).replace(" ", "")
		output += "Node %d (%s): prev=%s, next=%s, type=%s, reliability=%.2f\n" % [
			node_id,
			node["name"],
			prev_str,
			next_str,
			node["type"],
			node["reliability"]
		]
	LogUtil.info(output)
	return output
#endregion
