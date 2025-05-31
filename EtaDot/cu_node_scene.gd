extends Panel

@export var component: Component

# ----- Structure -----
# NodeName: String
# NodeType: String
# <Short Desc>
# Reliability: float
# Unreliability: float
# ---------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# FIXME: Priorize `textEdit` and `OptionButton`
	# NodeName
	$"VBox/Grid1/NameEdit".text = component.node_name
	# NodeTypes
	var selection = $"VBox/Grid1/TypeSelection"
	for typename in GlobalData.nodetypes_data.get_all_typenames():
		if typename != "Initial":
			selection.add_item(typename)
	## Initially select correspondent item
	for typeidx in range(selection.item_count):
		if selection.get_item_text(typeidx) == component.node_type:
			selection.select(typeidx)
			break
	# Short Description
	_on_option_button_item_selected(selection.selected)
	# Reliability and Failure
	$"VBox/Grid2/ReliEdit".text = str(component.reliability)
	$"VBox/Grid2/FailEdit".text = str(1-component.reliability)

func _on_option_button_item_selected(index: int) -> void:
	var typename = $VBox/Grid1/TypeSelection.get_item_text(index)
	var showdesc = $VBox/ShowDesc
	showdesc.text = GlobalData.nodetypes_data.get_type_by_name(typename).short_desc


#region Sync Reli & Fail
func _update_values(source_edit: Node, target_edit: Node, is_reliability: bool) -> void:
	var text = source_edit.text
	if text.is_valid_float():
		var value = float(text)
		if is_valid_value(value):
			component.reliability = value if is_reliability else 1 - value
			target_edit.text = str(1 - value)
		else:
			target_edit.text = "Invalid data"
	else:
		target_edit.text = "Invalid data"
	# LogUtil.info("%s updated: %s" % ["Reliability" if is_reliability else "Failure", text])

func _on_reli_edit_text_changed() -> void:
	_update_values($VBox/Grid2/ReliEdit, $VBox/Grid2/FailEdit, true)

func _on_fail_edit_text_changed() -> void:
	_update_values($VBox/Grid2/FailEdit, $VBox/Grid2/ReliEdit, false)

func is_valid_value(value: float) -> bool:
	return value > 0.0 and value <= 1.0
#endregion


func _on_confirm_button_pressed() -> void:
	# Check valid data
	if $VBox/Grid2/ReliEdit.text.is_valid_float() == false or $VBox/Grid2/FailEdit.text.is_valid_float() == false:
		LogUtil.error_dialog(get_parent().get_parent(),"[color=yellow]Reliability / Failure [/color] invalid!")
		return
	# Update `Component` (Except reliability)
	component.node_name = $"VBox/Grid1/NameEdit".text
	var option_button = $"VBox/Grid1/TypeSelection"
	component.node_type = option_button.get_item_text(option_button.selected)
	# Sync with `GlobalData`
	GlobalData.components_data.update_component(component)
	GlobalData.save_components()
	queue_free()


func _on_cancel_button_pressed() -> void:
	queue_free()
