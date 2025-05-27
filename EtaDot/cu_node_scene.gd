extends Panel

@export var component: Component

# NodeName: String
# NodeType: String
# <Short Desc>
# Reliability: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# FIXME: Priorize `textEdit` and `OptionButton`
	# NodeName
	$"VBox/Grid1/NameEdit".text = component.node_name
	# NodeTypes
	for typename in GlobalData.nodetypes_data.get_all_typenames():
		if typename != "Initial":
			$VBox/Grid1/OptionButton.add_item(typename)
	# Short Description
	_on_option_button_item_selected($VBox/Grid1/OptionButton.selected)
	# Reliability
	$"VBox/Grid2/ReliEdit".text = str(component.reliability)

func _on_option_button_item_selected(index: int) -> void:
	var typename = $VBox/Grid1/OptionButton.get_item_text(index)
	var showdesc = $VBox/ShowDesc
	showdesc.text = GlobalData.nodetypes_data.get_type_by_name(typename).short_desc
