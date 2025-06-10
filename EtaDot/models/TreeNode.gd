extends Sprite2D
class_name TreeNode

# Node attributes
@export var x: float = 0.0  # Node's x coordinate in the tree
@export var y: float = 0.0  # Node's y coordinate in the tree
@export var layer: int = 0   # Node's layer in the tree (0 is root)
@export var in_parent_index: int = 0  # Index position in parent node
@export var parents: Array = []       # Array of parent nodes (supports multiple parents)
@export var childs: Array = []        # Array of child nodes
@export var comp: Component # Embedded `Component`

# Add a parent node
func add_parent_node(parent_node) -> void:
	# Avoid duplicate additions
	if not parents.has(parent_node):
		parents.append(parent_node)

# Add a child node
func add_child_node(child_node) -> void:
	# Avoid duplicate additions
	if not childs.has(child_node):
		childs.append(child_node)
		# Set the child node's parent simultaneously
		child_node.add_parent_node(self)
