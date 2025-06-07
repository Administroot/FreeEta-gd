class_name Algor

# Constants
const MIN_X_SPACING := 100
const MAX_Y_SPACING := 40

#region Tree layout algorithm
##### Main Entrance #####
static func create_components(scene: Node) -> void:
	var comps_dict = components_to_dict(GlobalData.components_data)
	var root_nodes = find_root_nodes(comps_dict)
	
	for root in root_nodes:
		layout_tree(root, 0, 0, comps_dict, scene)

static func components_to_dict(comps: Components) -> Dictionary:
	var dict = {}
	# First create the basic dictionary
	for comp in comps.components:
		var next = []
		for other in comps.components:
			if other.prev_node.has(comp.node_id):
				next.append(other.node_id)
				
		dict[comp.node_id] = {
			"id": comp.node_id,
			"name": comp.node_name,
			"type": comp.node_type,
			"reliability": comp.reliability,
			"prev": comp.prev_node,
			"next": next,
			"layer": 0  # Initialize layer to 0
		}
	
	# Calculate layers starting from root nodes
	var roots = []
	for id in dict:
		if dict[id]["prev"].is_empty():
			roots.append(id)
			
	# Traverse from each root and set layers
	for root in roots:
		var queue = [{id = root, layer = 0}]
		while not queue.is_empty():
			var current = queue.pop_front()
			dict[current.id]["layer"] = current.layer
			for child_id in dict[current.id]["next"]:
				queue.append({id = child_id, layer = current.layer + 1})
	LogUtil.info(print_adjacency_list(dict))
	return dict

static func find_root_nodes(dict: Dictionary) -> Array:
	var roots = []
	for node_id in dict:
		if dict[node_id]["prev"].is_empty():
			roots.append(node_id)
	return roots

static func layout_tree(node_id: int, x: int, y: int, dict: Dictionary, scene: Node) -> void:
	# Load the component scene
	var comp_scene = load("res://component.tscn").instantiate()
	comp_scene.position = Vector2(x * MIN_X_SPACING, y * MAX_Y_SPACING)
	
	# Set up the component data
	var node_data = dict[node_id]
	var comp = Component.new()
	comp.node_id = node_id
	comp.node_name = node_data["name"]
	comp.node_type = node_data["type"]
	comp.reliability = node_data["reliability"]
	comp.prev_node = node_data["prev"]
	comp_scene.component = comp
	
	# Add to scene tree
	scene.add_child(comp_scene)
	
	# Recursively layout children
	var child_x = x + 1
	for i in range(node_data["next"].size()):
		var child_id = node_data["next"][i]
		var child_y = y + i
		layout_tree(child_id, child_x, child_y, dict, scene)
#endregion

#region Debugging
static func print_adjacency_list(dict: Dictionary) -> String:
	var output = "Component Graph Structure:\n"
	
	for node_id in dict:
		var node = dict[node_id]
		var prev_str = str(node["prev"]).replace(" ", "")
		var next_str = str(node["next"]).replace(" ", "")
		output += "Node %d (%s): prev=%s, next=%s, type=%s, reliability=%.2f, layer=%d\n" % [
			node_id,
			node["name"],
			prev_str,
			next_str,
			node["type"],
			node["reliability"],
			node["layer"]
		]
	return output
#endregion