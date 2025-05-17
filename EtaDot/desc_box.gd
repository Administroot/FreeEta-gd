extends HSplitContainer


func _on_node_list_show_node_info(node: NodeType) -> void:
	$GridContainer/NodeName.text = "[b][color=orange]" + node.type_name + "[/color][/b]"
	$GridContainer/NodeShortDesc.text = "[b]" + node.short_desc + "[/b]"
	$GridContainer/NodeLongDesc.text = node.long_desc
	$NodePhoto.texture = load(node.sprite_path)
