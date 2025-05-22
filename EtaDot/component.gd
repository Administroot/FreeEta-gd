extends RigidBody2D

@export var Id := get_instance_id()
@export var size := Vector2()
var dragging := false
var drag_offset := Vector2()
var panel: Node = null

func _ready() -> void:
	set_properties("res://assets/pump.svg")
	
func set_properties(picture: String) -> void:
	$Photo.texture = load(picture)
	size = $Photo.texture.get_size()
	$CollisionShape.shape.size = size
	$Button.size = size
	$Button.position = - size / 2.

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

## While pressing MOUSE_BUTTON_LEFT and dragging: dragging
## While pressing MOUSE_BUTTON_RIGHT: show node statics
## While pressing ENTER: create a brother bode
## While pressing TAB: create a sub-node
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					# Begin dragging
					if $Button.get_global_rect().has_point(event.global_position):
						dragging = true
						drag_offset = event.global_position - global_position
				else:
					# After dragging
					dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		# Update position
		global_position = event.global_position - drag_offset


func _on_button_pressed() -> void:
	if panel:
		panel.queue_free()
		panel = null

func _on_right_button_pressed() -> void:
	if not panel:
		panel = load("res://CU_node_scene.tscn").instantiate()
		# Increase priority
		panel.z_index = 100
		add_child(panel)
		await panel.tree_exited


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_on_right_button_pressed()
