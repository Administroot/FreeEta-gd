extends MenuBar

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		# 🌏 About FreeEta
		1: $HelpMenu/AboutFreeetaScene.popup_centered()

func _on_graphics_menu_id_pressed(id: int) -> void:
	match id:
		# ➕ Add More ...
		2: $GraphicsMenu/CreateNodeScene.popup_centered()
