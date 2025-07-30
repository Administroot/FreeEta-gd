extends Node2D

var wait_dialog = preload("res://WaitingScene.tscn").instantiate()

func _ready() -> void:
	wait_dialog.name = "WaitingScene"
	wait_dialog.connect("ready_completed", _on_wait_dialog_ready)
	add_child.call_deferred(wait_dialog)
	#wait_dialog.call_deferred("hide_wait")

func _on_wait_dialog_ready() -> bool:
	return true

func _on_calculator_start_calculation() -> void:
	LogUtil.info("Analyzing Event Tree ...")
	if _on_wait_dialog_ready():
		wait_dialog.call_deferred("show_wait")
	else :
		LogUtil.error("[color=yellow]wait_dialog[/color] Not ready")

func _on_calculator_calculator_prepared() -> void:
	LogUtil.info("ETA calculation finished!")
	if _on_wait_dialog_ready():
		wait_dialog.call_deferred("hide_wait")
	else :
		LogUtil.error("[color=yellow]wait_dialog[/color] Not ready")

func _on_tree_exiting() -> void:
	#wait_dialog.queue_free()
	pass
