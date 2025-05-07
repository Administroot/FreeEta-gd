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
	label.set_editable(0, false)

# When user press specific node tree item
func _on_node_list_cell_selected() -> void:
	var treeitem = node_list.get_selected()
	var node_id = data.get_type(treeitem.get_index())
	if node_id:
		LogUtil.info("Treeitem %s Selected" % treeitem.get_text(0))
		# Then show up
		desc_box.get_node("GridContainer/NodeName").text = "[b][color=orange]" + node_id.node_name + "[/color][/b]"
		desc_box.get_node("GridContainer/NodeShortDesc").text = "[b]" + node_id.short_desc + "[/b]"
		desc_box.get_node("GridContainer/NodeLongDesc").text = node_id.long_desc
		$HSplit1/NodeBox/DescBox/NodePhoto.texture = load(node_id.sprite_path)
	else:
		LogUtil.error("Node data not found in Json")
		push_error("Node data not found in Json")

# Submit and add a `TreeItem`
#region Add Node
func _on_add_node_line_edit_text_submitted(new_text: String) -> void:
	add_node(new_text)

func _on_button_pressed() -> void:
	add_node($"HSplit1/NodeBox/HBox1/AddNodeLineEdit".text)

func add_node(new_node_name: String) -> void:
	for node_name in TreeUtil.get_column_item_names(node_list):
		if node_name == new_node_name:
			# Pop a warning panel
			var warning = "Your new NodeType Name [b][color=yellow]{name}[/color][/b] is duplicated with the existing node name."
			LogUtil.warning_dialog($".", warning.format({"name": new_node_name}))
			return
	# Pop add node panel.
	var add_node_type_panel = preload("res://CU_node_type_scene.tscn").instantiate()
	add_node_type_panel.get_node("VBoxContainer/VBox/Grid/NameEdit").text = new_node_name
	add_node_type_panel.nodetype = NodeType.new()
	add_child(add_node_type_panel)
	# And clear the text
	$"HSplit1/NodeBox/HBox1/AddNodeLineEdit".clear()
	# Wait for panel response
	await add_node_type_panel.tree_exited
	# When ConfirmButton pressed, print success info
	if add_node_type_panel.choice and add_node_type_panel.nodetype:
		var info = "NodeType [b][color=blue]{name}[/color][/b] created successfully!"
		# Add node to tree
		create_label(node_list.get_root(), add_node_type_panel.nodetype)
		# TODO: Serialize the new node to Json
		LogUtil.info(info.format({"name": new_node_name}))

#region JSON Serialize and Deserialize
func get_nodes() -> NodeTypes:
	var loaded_data: NodeTypes = JsonClassConverter.json_file_to_class(NodeTypes, "user://saves/node_types.json")
	if !loaded_data:
		LogUtil.error("Error loading node data.")
		push_error("Error loading node data.")
	return loaded_data

func save_nodes() -> void:
	# TODO: Serialize the new node to Json
	pass


func _on_node_list_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	# TODO: Share panel with `CU_Node_Type_Scene`
	pass # Replace with function body.
