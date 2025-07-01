extends PopupPanel

signal confirmed
signal canceled

@export var msg = ""

func _ready() -> void:
	$VBox/MsgLabel.text = msg

func _on_confirm_button_pressed() -> void:
	emit_signal("confirmed")
	queue_free()


func _on_cancel_button_pressed() -> void:
	emit_signal("canceled")
	queue_free()
