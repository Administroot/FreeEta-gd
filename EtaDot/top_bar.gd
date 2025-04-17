extends MenuBar

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		# 🌏 About FreeEta
		1: $HelpMenu/AboutFreeetaScene.popup_centered()
