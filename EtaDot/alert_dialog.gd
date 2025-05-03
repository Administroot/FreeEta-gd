extends PopupPanel

@export var msg = ""

func _ready() -> void:
	$"VBoxContainer/MsgLabel".text = msg

func _on_confirm_button_pressed() -> void:
	queue_free()
