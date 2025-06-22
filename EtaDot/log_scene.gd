extends PopupPanel

@onready var msg_label = $"VBox/ScrollContainer/MsgLabel"

#TODO: Always scroll to the bottom of `ScrollConatiner`

func _on_problem_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		msg_label.text = GlobalData.error_logger
	else :
		msg_label.text = ""


func _on_output_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		msg_label.text = GlobalData.global_logger
	else :
		msg_label.text = ""
