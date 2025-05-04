extends PopupPanel

@export var choice: bool
	
func _on_confirm_button_pressed() -> void:
	choice = true
	queue_free()


func _on_cancel_button_pressed() -> void:
	choice = false
	queue_free()


func _on_select_button_pressed() -> void:
	$"VBoxContainer/HBox/FileDialog".show()
