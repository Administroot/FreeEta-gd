extends CanvasLayer

signal refresh

@export var component: Component
var all_node_selections: Array[Node] = []
var all_del_prev_buttons: Array[Node] = []

# ----- Structure -----
# NodeName: String
# NodeType: String
# <Short Desc>
# Reliability: float
# Unreliability: float
# ---------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NodeName
	$"Panel/VBox/Grid1/NameEdit".text = component.node_name
	# NodeTypes
	var selection = $"Panel/VBox/Grid1/TypeSelection"
	for typename in GlobalData.nodetypes_data.get_all_typenames():
		if typename != "Initial":
			selection.add_item(typename)
	## Initially select correspondening item
	for typeidx in range(selection.item_count):
		if selection.get_item_text(typeidx) == component.node_type:
			selection.select(typeidx)
			break
	# Short Description
	_on_type_selection_item_selected(selection.selected)
	# Reliability and Failure
	$"Panel/VBox/Grid2/ReliEdit".text = str(component.reliability)
	$"Panel/VBox/Grid2/FailEdit".text = str(1-component.reliability)
	# Prev Node
	var node_grid = $"Panel/VBox/Grid2/NodeVBox/NodeGrid"
	var node_selection = node_grid.get_node("NodeSelection")
	var del_prev_button = node_grid.get_node("DelPrevButton")
	## Create corresponding number of `Prev Node` blocks
	for num in len(component.prev_node):
		var new_selection = node_selection.duplicate()
		new_selection.show()
		for node_name in GlobalData.components_data.get_all_component_names():
			# Neglect itself `node_id`
			if component.node_name != node_name:
				new_selection.add_item(node_name)
		node_grid.add_child(new_selection)
		all_node_selections.append(new_selection)
		var new_del_button = del_prev_button.duplicate()
		new_del_button.show()
		node_grid.add_child(new_del_button)
		all_del_prev_buttons.append(new_del_button)
	## Initially select correspondening `Prev Node`
	for i in range(len(all_node_selections)):
		var node_id = component.prev_node[i]
		var idx = GlobalData.components_data.get_components_id().find(node_id)
		if idx < 0:
			LogUtil.error_dialog(get_parent().get_parent(),"Node id [color=red]%s[/color] Not Found!" % node_id)
		else:
			all_node_selections[i].select(idx)
	# Adjust `Panel`'s height
	adjust_height(0)

func _on_type_selection_item_selected(index: int) -> void:
	var typename = $"Panel/VBox/Grid1/TypeSelection".get_item_text(index)
	var showdesc = $"Panel/VBox/ShowDesc"
	showdesc.text = GlobalData.nodetypes_data.get_type_by_name(typename).short_desc

#region Sync Reli & Fail
var flag := false

func _update_values(source_edit: Node, target_edit: Node, is_reliability: bool) -> void:
	var text = source_edit.text
	if text.is_valid_float():
		var value = float(text)
		if is_valid_value(value):
			component.reliability = value if is_reliability else 1 - value
			target_edit.text = str(1 - value)
			flag = true
		else:
			target_edit.text = "Invalid data"
	else:
		target_edit.text = "Invalid data"
	# LogUtil.info("%s updated: %s" % ["Reliability" if is_reliability else "Failure", text])

func _on_reli_edit_text_changed() -> void:
	_update_values($Panel/VBox/Grid2/ReliEdit, $Panel/VBox/Grid2/FailEdit, true)

func _on_fail_edit_text_changed() -> void:
	_update_values($Panel/VBox/Grid2/FailEdit, $Panel/VBox/Grid2/ReliEdit, false)

func is_valid_value(value: float) -> bool:
	return value > 0.0 and value <= 1.0
#endregion


func _on_confirm_button_pressed() -> void:
	var old_comp = component.duplicate()
	# Check valid data
	if $"Panel/VBox/Grid2/ReliEdit".text.is_valid_float() == false or $"Panel/VBox/Grid2/FailEdit".text.is_valid_float() == false:
		LogUtil.error_dialog(get_parent().get_parent(),"[color=yellow]Reliability / Failure [/color] invalid!")
		return
	# Check `NULL` value
	if $"Panel/VBox/Grid1/NameEdit".text == "" or $"Panel/VBox/Grid2/ReliEdit".text == "" or $"Panel/VBox/Grid2/FailEdit".text == "":
		LogUtil.error_dialog(get_parent().get_parent(), "[color=red]NULL[/color] value exists, please fill in!")
		return
	# Update `Component` (Except reliability)
	component.node_name = $"Panel/VBox/Grid1/NameEdit".text
	var option_button = $"Panel/VBox/Grid1/TypeSelection"
	component.node_type = option_button.get_item_text(option_button.selected)
	# Update `Prev Node`
	component.prev_node.clear()
	for nodeselection in all_node_selections:
		var prev_name = nodeselection.get_item_text(nodeselection.selected)
		var prev_id = GlobalData.components_data.get_component_by_name(prev_name).node_id
		component.prev_node.append(prev_id)
	# Check if there are any duplicates in `prev_node`
	var seen_nodes = []
	for node_id in component.prev_node:
		if node_id in seen_nodes:
			LogUtil.error_dialog(get_parent().get_parent(), "[color=red]Duplicated[/color] [color=pink]PrevNode[/color] are not allowed!")
			return
		seen_nodes.append(node_id)
	# Check if new component is the same as the old one
	# Node `Component` didn't change and reli/fail didn't change
	if old_comp.equal(component) and !flag:
		LogUtil.warning("The new [color=blue]Component[/color] is the same as old one. Do nothing")
		queue_free()
		return
	#### Sync with `GlobalData` ####
	GlobalData.push_recent_component_type(component.get_nodetype_by_component())
	GlobalData.components_data.update_component(component)
	GlobalData.save_components()
	################################
	LogUtil.info("New Component Created!")
	component.printall()
	queue_free()


func _on_cancel_button_pressed() -> void:
	queue_free()

# Delete a `Prev Node` relation
func _on_del_prev_button_pressed() -> void:
	var seq = 0
	for button in all_del_prev_buttons:
		if button.is_pressed() == true:
			all_node_selections[seq].queue_free()
			all_del_prev_buttons[seq].queue_free()
			all_node_selections.remove_at(seq)
			all_del_prev_buttons.remove_at(seq)
			break
		seq += 1
	adjust_height(-1)

# Add a `Prev Node` relation
func _on_add_prev_button_pressed() -> void:
	var node_grid = $"Panel/VBox/Grid2/NodeVBox/NodeGrid"
	var node_selection = node_grid.get_node("NodeSelection")
	var del_prev_button = node_grid.get_node("DelPrevButton")
	var new_selection = node_selection.duplicate()
	var new_del_button = del_prev_button.duplicate()
	for node_name in GlobalData.components_data.get_all_component_names():
		# Neglect itself `node_id`
		if component.node_name != node_name:
			new_selection.add_item(node_name)
	new_selection.show()
	new_del_button.show()
	all_node_selections.append(new_selection)
	all_del_prev_buttons.append(new_del_button)
	node_grid.add_child(new_selection)
	node_grid.add_child(new_del_button)
	adjust_height(1)

# Automatically adjust `Panel`'s height
# `choice`:
#	- `-1` : delete a `prev_node`
#   - `0` : recalculate `Panel` height
#   - `1`: add a `prev_node` 
func adjust_height(choice: int) -> void:
	const grid_height := 38
	const v_sep := 4
	var grid = $"Panel/VBox/Grid2/NodeVBox/NodeGrid"
	var panel_h = $Panel.size.y
	match choice:
		0: 
			var child_count = grid.get_child_count()
			panel_h += (child_count / 2. - 1.) * grid_height
			panel_h += v_sep
		-1:
			panel_h -= grid_height
			panel_h -= v_sep
		1:
			panel_h += grid_height
			panel_h += v_sep
	$Panel.size.y = int(panel_h)


func _on_del_button_pressed() -> void:
	var dialog = preload("res://ConfirmDialog.tscn").instantiate()
	dialog.msg = "Delete Node [color=red]{node_name}[/color]".format({"node_name": component.node_name})
	dialog.confirmed.connect(_execute_delete)
	dialog.canceled.connect(_cancel_delete)
	add_child(dialog)

func _execute_delete() -> void:
	GlobalData.components_data.delete_component(component)
	GlobalData.save_components()
	emit_signal("refresh")

func _cancel_delete() -> void:
	# DO NOTHING
	pass
