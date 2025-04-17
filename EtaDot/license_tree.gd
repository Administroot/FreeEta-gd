extends Tree

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	print("--- 按钮点击事件触发 ---")
	print("节点文本: ", item.get_text(column))  # 打印节点当前列文本
	print("列索引: ", column)
	print("按钮ID: ", id)
	
	# 将鼠标按键索引转为可读文本
	var mouse_button = ""
	match mouse_button_index:
		1: mouse_button = "左键"
		2: mouse_button = "右键"
		3: mouse_button = "中键"
		_: mouse_button = str(mouse_button_index)
	print("鼠标按键: ", mouse_button)


func _on_column_title_clicked(column: int, mouse_button_index: int) -> void:
	print("column=", column)
	print("mouse_button_index=", mouse_button_index)
	print()


func _on_item_selected() -> void:
	print("Item Selected!")


func _on_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	pass # Replace with function body.
