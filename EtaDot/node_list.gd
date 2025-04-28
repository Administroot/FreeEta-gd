extends Tree

func _on_item_edited() -> void:
	var treeitem = get_edited()
	if treeitem != null and treeitem.get_text(0) == "":
		treeitem.free()
