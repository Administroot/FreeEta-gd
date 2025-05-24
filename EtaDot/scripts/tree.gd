# Utility for `Tree` nodetype in `Godot`
class_name TreeUtil

static func get_column_item_names(tree: Tree, column: int = 0) -> PackedStringArray:
	var names: Array[String] = []
	var root = tree.get_root()
	if root:
		_traverse_items(root, names, column)
	return PackedStringArray(names)

static func _traverse_items(item: TreeItem, names: Array[String], column: int) -> void:
	names.append(item.get_text(column))
	var child = item.get_first_child()
	while child:
		_traverse_items(child, names, column)
		child = child.get_next()