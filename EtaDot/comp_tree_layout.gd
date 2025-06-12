extends Control

# Layout parameters
@export var spacing_x: float = 200.0 # Horizontal spacing between nodes
@export var spacing_y: float = 50.0 # Vertical spacing between nodes
# TODO: Dynamically adjust width / height
@export var node_width: float = 200.0 # Node width
@export var node_height: float = 200.0 # Node height

var x_interval: float # Node horizontal interval (width + spacing)
var y_interval: float # Node vertical interval (height + spacing)

var root: TreeNode # Root node
var hash_nodes: Array = [] # Array of nodes stored by level


# Initialization function
func _ready():
	# Dataset
	dataset()
	# Calculate actual intervals
	x_interval = node_width + spacing_x
	y_interval = node_height + spacing_y
	
	# Find root node (first child node of TreeNode type)
	for child in get_children():
		if child is TreeNode:
			root = child
			break
	if not root:
		LogUtil.error("Please set root node!")
		push_error("Please set root node!")
		return
	
	# Initialize tree structure
	init_tree()
	
	# Execute layout
	layout()

func dataset() -> void:
	# Convert components data into TreeNodes
	for comp in GlobalData.components_data.components:
		var current_node = TreeNode.new()
		current_node.name = str(comp.node_id)
		current_node.comp = comp
		add_child(current_node)
		for prev_id in comp.prev_node:
			var prev_node = get_node(str(prev_id))
			prev_node.add_child_node(current_node)

# Initialize tree structure
func init_tree():
	# Reset level nodes array
	hash_nodes = []
	
	# Start recursive initialization from root node
	init_node(root)

# Recursively initialize nodes
func init_node(node: TreeNode):
	# If root node, set level to 0
	if node == root:
		node.layer = 0
	
	# Add node to corresponding level
	add_hash_node(node)
	
	# Process all child nodes
	for i in range(node.childs.size()):
		var child = node.childs[i]
		# Set parent node relationship
		child.add_parent_node(node)
		# Child node level is parent level + 1
		child.layer = node.layer + 1
		# Record index position in parent node
		child.in_parent_index = i
		# Recursively initialize child node
		init_node(child)

# Add node to level array
func add_hash_node(node: TreeNode):
	# Ensure level array is large enough
	while hash_nodes.size() <= node.layer:
		hash_nodes.append([])
	
	# Get node list for current level
	var layer_nodes = hash_nodes[node.layer]
	
	# Avoid duplicate additions
	if not layer_nodes.has(node):
		layer_nodes.append(node)

# Execute layout
func layout():
	# Layout child nodes
	layout_child(root)
	# Handle node overlapping
	layout_overlaps()
	# Refresh node positions
	refresh_node_position(root)

# Recursively layout child nodes
func layout_child(node: TreeNode):
	# If root node, use current position
	if node == root:
		node.x = position.x
		node.y = position.y
	
	# Iterate through all child nodes
	for i in range(node.childs.size()):
		var child = node.childs[i]
		
		# Get parent node center Y coordinate (average if multiple parents)
		var center_y = get_center_y_by_parents(child.parents)
		
		# Calculate child node starting Y coordinate (center children vertically to parent)
		var start = center_y - (node.childs.size() - 1) * y_interval / 2.0
		# Calculate target Y coordinate (based on index in parent)
		var target_y = start + child.in_parent_index * y_interval
		
		# Set child node X coordinate (to right of parent)
		child.x = node.x + x_interval
		
		# Calculate required movement distance
		var dy = target_y - child.y
		# If movement needed, move subtree
		if abs(dy) > 0.01:
			translate_tree(child, child.y + dy)
		
		# Recursively layout child nodes
		layout_child(child)

# Move subtree to new Y coordinate
func translate_tree(node: TreeNode, new_y: float):
	# Calculate movement distance
	var dy = new_y - node.y
	# Update current node Y coordinate
	node.y = new_y
	
	# Recursively move all child nodes
	for child in node.childs:
		# If node has multiple parents, need to recalculate position
		if child.parents.size() > 1:
			var center_y = get_center_y_by_parents(child.parents)
			var start = center_y - (child.parents[0].childs.size() - 1) * y_interval / 2.0
			var target_y = start + child.in_parent_index * y_interval
			dy = target_y - child.y
		
		# Recursively move subtree
		translate_tree(child, child.y + dy)

# Get Y coordinate of parent node center
func get_center_y_by_parents(parents: Array) -> float:
	# If no parents, return 0
	if parents.size() == 0:
		return 0.0
	
	# If single parent, return its Y coordinate
	if parents.size() == 1:
		return parents[0].y
	
	# If multiple parents, return average of first and last parent
	return (parents[0].y + parents[parents.size() - 1].y) / 2.0

# Refresh node positions (update actual display position)
func refresh_node_position(node: TreeNode, processed_nodes: Dictionary = {}):
	if processed_nodes.has(node.name):
		return
	processed_nodes[node.name] = true
	# Set node rectangle position
	node.position = Vector2(node.x, node.y)
	
	# Draw lines to child nodes
	for child in node.childs:
		####################################################
		# Set line points from parent center to child center
		var gap_y = Vector2(node_width / 2., 0.)
		var start = node.position + gap_y
		var end = Vector2(child.x + node_width/2., child.y + node_height/2.) - Vector2(node_width, 0.5 * node_height)
		draw_linemap(start, end)
		####################################################
		# Recursively refresh child node
		refresh_node_position(child, processed_nodes)
	var scene = load("res://component.tscn").instantiate()
	scene.position = node.position
	scene.component = node.comp
	get_parent().get_node("TreeComps").add_child(scene)

# Handle node overlapping
func layout_overlaps():
	# Traverse all levels from bottom up
	var restart = true
	while restart:
		restart = false
		# Check from bottom layer upwards
		for layer_index in range(hash_nodes.size() - 1, -1, -1):
			var layer_nodes = hash_nodes[layer_index]
			# Sort by Y coordinate
			layer_nodes.sort_custom(sort_nodes_by_y)
			
			# Check if adjacent nodes overlap
			for j in range(layer_nodes.size() - 1):
				var node1 = layer_nodes[j]
				var node2 = layer_nodes[j + 1]
				
				# If overlapping (vertical distance less than interval)
				if is_overlaps(node1, node2):
					# Find ancestor node of node2 under common ancestor
					var move_node = get_common_parent_n2_parent(node1, node2)
					# Move up by one interval
					var new_y = move_node.y - y_interval
					# Move subtree
					translate_tree(move_node, new_y)
					# Center children of parent node
					center_child(move_node.parents)
					# Set restart flag (need to recheck all levels)
					restart = true
					# Break inner loop
					break
			
			# If restarting, break outer loop
			if restart:
				break

# Sort nodes by Y coordinate
func sort_nodes_by_y(a: TreeNode, b: TreeNode) -> bool:
	return a.y < b.y

# Check if two nodes overlap
func is_overlaps(node1: TreeNode, node2: TreeNode) -> bool:
	# Nodes overlap if vertical distance is less than interval
	return (node2.y - node1.y) < y_interval

# Find node2's ancestor under the common ancestor of two nodes
func get_common_parent_n2_parent(node1: TreeNode, node2: TreeNode) -> TreeNode:
	# If direct parents are the same, return node2
	if node1.parents[0] == node2.parents[0]:
		return node2
	
	# Recursively search parent nodes
	return get_common_parent_n2_parent(node1.parents[0], node2.parents[0])

# Center children nodes relative to parent
func center_child(parents: Array):
	# Return if no parents
	if parents.size() == 0:
		return
	
	# Only consider first parent
	var parent_node = parents[0]
	# Get center Y coordinate of child nodes
	var center_y = get_center_y_by_childs(parent_node.childs)
	# Parent node center Y coordinate
	var parent_center_y = parent_node.y
	# Calculate required adjustment distance
	var dy = parent_center_y - center_y
	
	# Adjust all child nodes
	for child in parent_node.childs:
		translate_tree(child, child.y + dy)

# Get center Y coordinate of child nodes list
func get_center_y_by_childs(childs: Array) -> float:
	# Return 0 if no children
	if childs.size() == 0:
		return 0.0
	
	# Calculate minimum and maximum Y values
	var min_y = childs[0].y
	var max_y = childs[0].y
	
	for i in range(1, childs.size()):
		var y = childs[i].y
		min_y = min(min_y, y)
		max_y = max(max_y, y)
	
	# Return center value
	return (min_y + max_y) / 2.0

func draw_linemap(start_point: Vector2, end_point: Vector2) -> void:
	var linemap = load("res://linemap.tscn").instantiate()
	if start_point.y == end_point.y:
		linemap.points = [start_point, end_point]
	else :
		var middle_point = (start_point + end_point) / 2.
		var gap_y = Vector2(0., (end_point.y - start_point.y) / 2.)
		var points = [start_point, middle_point-gap_y, middle_point+gap_y, end_point]
		linemap.points = points
	get_parent().add_child(linemap)
