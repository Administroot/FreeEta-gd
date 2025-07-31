extends Node2D

signal calculator_prepared
signal start_calculation

func calculation_start() -> void:
	$Calculator.emit_signal("start_calculation")

func _on_calculator_calculator_prepared() -> void:
	emit_signal("calculator_prepared")

func _on_calculator_start_calculation() -> void:
	emit_signal("start_calculation")
