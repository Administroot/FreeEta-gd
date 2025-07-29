extends Node2D


func _on_calculator_start_calculation() -> void:
	LogUtil.info("Analyzing Event Tree ...")

func _on_calculator_calculator_prepared() -> void:
	LogUtil.info("ETA calculation finished!")
