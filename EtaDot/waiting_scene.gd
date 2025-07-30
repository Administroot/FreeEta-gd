extends PopupPanel
@onready var countdown = $VBox/HBox/CountDown
@onready var timer = $"Timer"
var current_time := 0.0

signal ready_completed

func _ready() -> void:
	emit_signal("ready_completed")

func show_wait():
	call_deferred("_deferred_show_wait")

func _deferred_show_wait():
	visible = true
	current_time = 0.0
	timer.start()

func hide_wait():
	call_deferred("_deferred_hide_wait")
	
func _deferred_hide_wait():
	timer.stop()
	# visible = false

func _on_timer_timeout() -> void:
	current_time += timer.wait_time
	countdown.text = "%.0f" % current_time + " s"
