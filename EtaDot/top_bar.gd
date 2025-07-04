extends MenuBar

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		# 🌏 About FreeEta
		1: 
			var scene := preload("res://about_freeeta_scene.tscn").instantiate()
			$"HelpMenu".add_child(scene)

func _on_graphics_menu_id_pressed(id: int) -> void:
	match id:
		# ➕ Add More ...
		2: 
			var scene := preload("res://node_type_management.tscn").instantiate()
			$"GraphicsMenu".add_child(scene)
