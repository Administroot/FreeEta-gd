extends PopupPanel

@export var choice: bool

func _on_confirm_button_pressed() -> void:
	# TODO: Hand in latest data
	choice = true
	queue_free()


func _on_cancel_button_pressed() -> void:
	choice = false
	queue_free()
