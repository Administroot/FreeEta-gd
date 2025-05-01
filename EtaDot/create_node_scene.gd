extends PopupPanel

@export var data = get_nodes()
@onready var node_list = $"HSplit1/NodeBox/NodeList"
@onready var desc_box = $"HSplit1/NodeBox/DescBox"

func _ready() -> void:
	
	var root = node_list.create_item()
	for i in range(len(data.types)):
		var node = data.get_type(i)
		create_label(root, node)
	
func create_label(parent: TreeItem, node: NodeType) -> void:
	var label = node_list.create_item(parent)
	label.set_text(0, node.node_name)
	label.set_custom_font_size(0, 25)
	label.add_button(0, load("res://assets/pen.png"), -1, false, "")
	label.set_editable(0, true)

# When user press specific node tree item
# TODO: When end editing, update json file.
func _on_node_list_item_edited() -> void:
	var treeitem = $"HSplit1/NodeBox/NodeList".get_edited()
	# Pick up
	var node = data.get_type(treeitem.get_index())
	if node == null:
		push_error("Node data not found in Json")
	else:
		LogUtil.info("TreeItem %s Select" % node)
	# Then show up
	desc_box.get_node("GridContainer/NodeName").text = "[b][color=orange]" + node.node_name + "[/color][/b]"
	desc_box.get_node("GridContainer/NodeShortDesc").text = "[b]" + node.short_desc + "[/b]"
	desc_box.get_node("GridContainer/NodeLongDesc").text = node.long_desc
	$HSplit1/NodeBox/DescBox/NodePhoto.texture = load(node.sprite_path)
	# Print name
	LogUtil.info(treeitem.get_text(0))

func get_nodes() -> NodeTypes:
	var loaded_data: NodeTypes = JsonClassConverter.json_file_to_class(NodeTypes, "user://saves/node_types.json") 
	if !loaded_data:
		push_error("Error loading node data.")
	return loaded_data

func save_nodes() -> void:
	pass
