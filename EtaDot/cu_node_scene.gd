extends Panel

@export var component: Component

# NodeName: String
# NodeType: String
# <Short Desc>
# Reliability: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"VBox/Grid1/NameEdit".text = component.node_name
	# TODO: `OptionButton` need to select from `NodeTypes`
	# TODO: `ShortDesc` need to read from `NodeTypes`
	$"VBox/Grid2/ReliEdit".text = str(component.reliability)
