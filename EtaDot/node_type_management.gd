extends PopupPanel

var data = GlobalData.nodetypes_data
@onready var node_list = $"HSplit1/NodeBox/NodeList"
@onready var desc_box = $"HSplit1/NodeBox/DescBox"
@onready var label_list = $"HSplit1/RecentBox/RecentList"

func _ready() -> void:
	var item_root = label_list.create_item()
	item_root.set_metadata(0, {"favor_flag": false})
	load_recent_members(item_root)

	var tree_root = node_list.create_item()
	for i in range(len(data.types)):
		var node = data.get_type(i)
		create_nodelist_member(tree_root, node, "res://assets/pen.png")

func create_nodelist_member(parent: TreeItem, node: NodeType, sprite_path: String) -> void:
	var label = node_list.create_item(parent)
	label.set_text(0, node.type_name)
	label.set_custom_font_size(0, 25)
	label.add_button(0, load(sprite_path), -1, false, "")
	label.set_editable(0, false)

func load_recent_members(root: TreeItem) -> void:
	# Remove duplicated members
	var recent: Array[String] = []
	for types in GlobalData.recently_created_component_types:
		if types.type_name not in recent:
			recent.append(types.type_name)
	# Find recent `NodeType`
	for typename in recent:
		create_recent_member(root, typename)

# When user press specific node tree item
func _on_node_list_cell_selected() -> void:
	var treeitem = node_list.get_selected()
	var node_selected = data.get_type(treeitem.get_index())
	if node_selected:
		# LogUtil.info("Treeitem %s Selected" % treeitem.get_text(0))
		# Then show up
		desc_box.get_node("GridContainer/NodeName").text = "[b][color=orange]" + node_selected.type_name + "[/color][/b]"
		desc_box.get_node("GridContainer/NodeShortDesc").text = "[b]" + node_selected.short_desc + "[/b]"
		desc_box.get_node("GridContainer/NodeLongDesc").text = node_selected.long_desc
		$HSplit1/NodeBox/DescBox/NodePhoto.texture = load(node_selected.sprite_path)
	else:
		LogUtil.error("Node data not found in Json")
		push_error("Node data not found in Json")

# Submit and add a `TreeItem`
#region Add Node
func _on_add_node_line_edit_text_submitted(new_text: String) -> void:
	add_node(new_text)

func _on_button_pressed() -> void:
	add_node($"HSplit1/NodeBox/HBox1/AddNodeLineEdit".text)

func add_node(new_type_name: String) -> void:
	for type_name in TreeUtil.get_column_item_names(node_list):
		if type_name == new_type_name:
			# Pop a warning panel
			var warning = "Your new NodeType Name [b][color=yellow]{name}[/color][/b] is duplicated with the existing node name."
			LogUtil.warning_dialog($".", warning.format({"name": new_type_name}))
			return
	# Pop add node panel.
	var add_node_type_panel = preload("res://CU_node_type_scene.tscn").instantiate()
	add_node_type_panel.modetitle = false
	add_node_type_panel.get_node("VBoxContainer/VBox/Grid/NameEdit").text = new_type_name
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
		create_nodelist_member(node_list.get_root(), add_node_type_panel.nodetype, "res://assets/pen.png")
		# Serialize new node to Json
		GlobalData.save_nodetypes(add_node_type_panel.nodetype, true)
		# Print success info
		LogUtil.info(info.format({"name": new_type_name}))
#endregion

#region Edit Node
func _on_node_list_button_clicked(item: TreeItem, column: int, _id: int, _mouse_button_index: int) -> void:
	var item_id = item.get_index()
	var node_selected = data.get_type(item_id)
	if item:
		var add_node_type_panel = preload("res://CU_node_type_scene.tscn").instantiate()
		add_node_type_panel.modetitle = false
		add_node_type_panel.get_node("VBoxContainer/VBox/Grid/NameEdit").text = node_selected.type_name
		add_node_type_panel.get_node("VBoxContainer/VBox/Grid/ShortDescEdit").text = node_selected.short_desc
		add_node_type_panel.get_node("VBoxContainer/VBox/Grid/LongDescEdit").text = node_selected.long_desc
		add_node_type_panel.get_node("VBoxContainer/VBox/NodeTexture").texture = load(node_selected.sprite_path)
		add_node_type_panel.nodetype = node_selected
		add_child(add_node_type_panel)
		# And clear the text
		$"HSplit1/NodeBox/HBox1/AddNodeLineEdit".clear()
		# Wait for panel response
		await add_node_type_panel.tree_exited
		# When ConfirmButton pressed, print success info
		if add_node_type_panel.choice and add_node_type_panel.nodetype:
			var info = "NodeType [b][color=blue]{name}[/color][/b] updated successfully!"
			# Update node in tree
			item.set_text(column, add_node_type_panel.nodetype.type_name)
			# Save the updated node to data
			GlobalData.save_nodetypes(add_node_type_panel.nodetype, false, item_id)
			# Print success info
			LogUtil.info(info.format({"name": add_node_type_panel.nodetype.type_name}))
	else :
		LogUtil.error("Item not found")
		push_error("Item not found")
#endregion

#region Recent
func create_recent_member(parent: TreeItem, label_name: String, path: String = "res://assets/dim-star.png") -> void:
	var label = label_list.create_item(parent)
	label.set_text(0, label_name)
	label.set_custom_font_size(0, 25)
	label.add_button(0, load(path), -1, false, "")
	label.set_editable(0, false)
	label.set_metadata(0, {"favor_flag": false})
#endregion

# Favor or not
func _on_recent_list_button_clicked(item: TreeItem, column: int, id: int, _mouse_button_index: int) -> void:
	if not item:
		var msg = "RecentBox item not found!"
		LogUtil.error_dialog($".", msg)
		push_error(msg)
		return
		
	item.erase_button(column, id)
	var metadata = item.get_metadata(column)
	if not metadata or not metadata.has("favor_flag"):
		var msg = "RecentBox metadata[favor_flag] not found!"
		LogUtil.error_dialog($".", msg)
		push_error(msg)
		return
	# Traverse favor_flag status
	metadata["favor_flag"] = !metadata["favor_flag"]

	var priority = metadata["favor_flag"]
	var sprite_path = "res://assets/star.png" if priority else "res://assets/dim-star.png"
	# If priority == true, raise the priority of the item.
	var parent = item.get_parent()
	if priority:
		# Move item to top
		item.move_before(parent.get_first_child())
	else:
		# Move item to bottom - traverse to find last child
		var last_child = parent.get_first_child()
		while last_child.get_next():
			last_child = last_child.get_next()
		item.move_after(last_child)
	item.add_button(column, load(sprite_path), id, false, "")
#endregion
