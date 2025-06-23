extends PopupPanel

@onready var msg_label = $"VBox/ScrollContainer/MsgLabel"
@onready var scroll = $"VBox/ScrollContainer"

#TODO: Always scroll to the bottom of `ScrollConatiner`
func reset_position_x() -> void:
	var size_x = get_size().x
	if size_x > 540:
		position = Vector2(1344 - size_x + 540 + 20, 88)

func _on_problem_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		msg_label.text = GlobalData.error_logger
	else :
		msg_label.text = ""
	reset_position_x()


func _on_output_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		msg_label.text = GlobalData.global_logger
	else :
		msg_label.text = ""
	reset_position_x()


func _on_clear_button_pressed() -> void:
	if $"VBox/HBox/ProblemButton".is_pressed():
		GlobalData.error_logger = ""
		msg_label.text = ""
	elif $"VBox/HBox/OutputButton".is_pressed():
		GlobalData.global_logger = ""
		msg_label.text = ""
