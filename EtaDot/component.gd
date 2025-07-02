extends Node2D

signal refresh
@export var size := Vector2()
@export var component: Component
var dragging := false
var drag_offset := Vector2()
var panel: Node = null

func _ready() -> void:
	var res = component.get_nodetype_by_component()
	if res:
		var pic_size = set_texture(res.sprite_path)
		set_text(component.node_name, pic_size)

# FIXME:  set_texture(): Loaded resource as image file, this will not work on export: 'res://assets/valve.svg'.
# Instead, import the image file as an Image resource and load it normally as a resource.
func set_texture(picture: String) -> Vector2:
	var image = Image.load_from_file(picture)
	var texture = ImageTexture.create_from_image(image)
	texture.set_size_override(size)
	$Photo.texture = texture
	$Button.size = size
	$Button.position = - size / 2.
	return size

func set_text(text: String, pos: Vector2) -> void:
	if text not in ["Initial", "Ending"]:
		$NameLabel.text = text
	else :
		$NameLabel.text = ""
	$NameLabel.position = Vector2(- pos.x / 2. + $NameLabel.get_size().x / 2., pos.y / 2.)

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

func _on_right_button_pressed(pos: Vector2) -> void:
	if not panel:
		# Init component
		panel = preload("res://CU_node_scene.tscn").instantiate()
		panel.get_node("Panel").position = pos
		panel.component = component
		panel.refresh.connect(_on_refresh_button_pressed)
		add_child(panel)
		await panel.tree_exited

# Deliver "refresh" signal to `main` scene
func _on_refresh_button_pressed() -> void:
	emit_signal("refresh")

func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Show panel
		_on_right_button_pressed(event.global_position)
	elif event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		# Create a `Component` (apposition)
		create_component_by_panel(true)
	elif event is InputEventKey and event.keycode == KEY_TAB and event.pressed:
		# Create a `Component` (tadem)
		create_component_by_panel(false)

# `mode`(bool): `True` for Apposition ; `False` for tadem
func create_component_by_panel(mode: bool) -> void:
	if not panel:
		panel = load("res://CU_node_scene.tscn").instantiate()
	else :
		return
	var selection_mode = GlobalData.selected_components.components.is_empty()
	var new_comp = Component.new()
	new_comp.node_id = get_instance_id()
	if mode:
		# `True` for Apposition
		new_comp.prev_node = component.prev_node
		panel.component = new_comp
		panel.get_node("Panel/VBox/title").text = "ℹ Create [u]Apposition[/u] Node"
	else :
		# `False` for tadem
		# selection mode == true, single selection mode;
		# selection mode == false, multiple selection mode
		panel.get_node("Panel/VBox/title").text = "ℹ Create [u]Tadem[/u] Node"
		if selection_mode:
			# TODO: Customize `prev_node`
			new_comp.prev_node = [component.node_id]
		else :
			# TODO: Customize `prev_node`
			new_comp.prev_node = GlobalData.selected_components.get_components_id()
		panel.component = new_comp
	panel.get_node("Panel").position = Vector2(960, 540)
	add_child(panel)
	GlobalData.push_recent_component_type(new_comp.get_nodetype_by_component())
	await panel.tree_exited
	emit_signal("refresh")
