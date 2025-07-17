extends Control

var min_scale: Vector2 = Vector2(0.1, 0.1)
var max_scale: Vector2 = Vector2(5.0, 5.0)
var zoom_step: float = 0.1

#region Boot Up
func _init() -> void:
	# Check saves
	var dir = DirAccess.open("user://saves")
	if dir == null:
		DirAccess.make_dir_absolute("user://saves")
	check_saves("node_types.json")
	check_saves("components.json")
	check_default_assets()
	# Mannually assign global varients
	GlobalData.components_data = GlobalData.get_components()
	GlobalData.nodetypes_data = GlobalData.get_nodetypes()

func check_saves(saves_name: String) -> void:
	if not FileAccess.file_exists("user://saves/" + saves_name):
		var source = FileAccess.open("res://examples/saves/" + saves_name, FileAccess.READ)
		var target = FileAccess.open("user://saves/" + saves_name, FileAccess.WRITE)
		target.store_string(source.get_as_text())
		source.close()
		target.close()

func check_default_assets() -> void:
	var src_dir_path = "res://assets"
	var dst_dir_path = "user://saves/assets"
	var src_dir = DirAccess.open(src_dir_path)
	var dst_dir = DirAccess.open(dst_dir_path)
	if dst_dir == null:
		DirAccess.make_dir_absolute(dst_dir_path)
		dst_dir = DirAccess.open(dst_dir_path)
	for file_name in src_dir.get_files():
		var src_file_path = src_dir_path + "/" + file_name
		var dst_file_path = dst_dir_path + "/" + file_name
		# Copy file if not exists or hash mismatch
		var need_copy = true
		if FileAccess.file_exists(dst_file_path):
			var src_file = FileAccess.open(src_file_path, FileAccess.READ)
			var dst_file = FileAccess.open(dst_file_path, FileAccess.READ)
			var src_hash = FileAccess.get_md5(src_file.get_as_text())
			var dst_hash = FileAccess.get_md5(dst_file.get_as_text())
			src_file.close()
			dst_file.close()
			if src_hash == dst_hash:
				need_copy = false
		if need_copy:
			var src_file = FileAccess.open(src_file_path, FileAccess.READ)
			var dst_file = FileAccess.open(dst_file_path, FileAccess.WRITE)
			dst_file.store_buffer(src_file.get_buffer(src_file.get_length()))
			src_file.close()
			dst_file.close()
#endregion

#region Ready
func _ready() -> void:
	# Connect signals from scene `BottomSlide`
	$"Scenes/BottomSlide".view_button_toggled.connect(on_view_button_toggled)
	$"Scenes/BottomSlide".eta_button_toggled.connect(on_eta_button_toggled)
	$"Scenes/BottomSlide".data_button_toggled.connect(on_data_button_toggled)
	$"Scenes/BottomSlide".log_button_toggled.connect(on_log_button_toggled)
	# Connect signals from scene `component`
	$"ContentControl/TreeComps".child_entered_tree.connect(_on_comp_added)
	# Print GlobalData
	GlobalData.print_global_data()

func _on_comp_added(child: Node) -> void:
	if child.has_signal("refresh"):
		child.refresh.connect(_on_refresh_button_pressed, CONNECT_DEFERRED)
#endregion

#region View
func on_view_button_toggled() -> void:
	clear_scenetree()
	$ZoomLabel.show()
	var scene = preload("res://CompTreeLayout.tscn").instantiate()
	scene.name = "CompTreeLayout"
	scene.position = Vector2(-200, 540)
	$Scenes.add_child(scene)

func clean_components() -> void:
	var tree_comps = $"ContentControl/TreeComps"
	if tree_comps:
		for child in tree_comps.get_children():
			child.queue_free()
	var lines = $"ContentControl/LineMaps"
	if lines:
		for child in lines.get_children():
			child.queue_free()
#endregion

#region ETA
func on_eta_button_toggled() -> void:
	clear_scenetree()
	$ZoomLabel.show()
	var scene = preload("res://EtaScene.tscn").instantiate()
	$Scenes.add_child(scene)
	# GlobalData.components_data.print_all_members("Components")
#endregion

#region RawData
func on_data_button_toggled() -> void:
	clear_scenetree()
	$ZoomLabel.hide()
	var data = preload("res://RawDataScene.tscn").instantiate()
	data.position = Vector2(0, 57)
	$Scenes.add_child(data)
#endregion

#region Logger
func on_log_button_toggled() -> void:
	var log_scene = preload("res://log_scene.tscn").instantiate()
	log_scene.position = Vector2(1344, 88)
	$".".add_child(log_scene)
#endregion

#region Utils
func clear_scenetree() -> void:
	clean_components()
	for child in $Scenes.get_children():
		if child.name != "TopSlide" and child.name != "BottomSlide":
			child.queue_free()
#endregion

#region Keybinding
var selection_mode = false
var is_dragging := false
var content_position := Vector2()
var move_speed: float = 5.0
var smoothing: float = 0.2

func _input(event: InputEvent) -> void:
	########## Selection Function ##########
	if event is InputEventKey and event.keycode == KEY_CTRL and event.pressed:
		selection_mode = true
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_TAB:
			pass
	elif event is InputEventMouseButton and selection_mode == true:
		# CTRL + LEFT_CLICK Selected
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			multiple_selection_mode()
	elif event is InputEventMouseMotion:
		pass
	else:
		single_selection_mode()
		selection_mode = false
	########################################
	########### Scroll Function ############
	if $Scenes.has_node("CompTreeLayout"):
		# FIXME: After creating `component`, scroll function lose efficacy.
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_scene(1 + zoom_step)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_scene(1 - zoom_step)
			# Using scroll to move `ContentControl`
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				is_dragging = event.pressed
				if is_dragging:
					content_position = position
		if is_dragging and event is InputEventMouseMotion:
			content_position += event.relative * move_speed
	########################################

#region Scroll
func _process(_delta: float) -> void:
	if is_dragging:
		$ContentControl.position = position.lerp(content_position, smoothing)
	else:
		content_position = position

#region Multiple Selection
func zoom_scene(factor: float):
	var content = $ContentControl
	if not content:
		return
	var new_scale = content.scale * factor
	new_scale.x = clamp(new_scale.x, min_scale.x, max_scale.x)
	new_scale.y = clamp(new_scale.y, min_scale.y, max_scale.y)
	content.scale = new_scale
	$ZoomLabel.text = "%.1f%%" % (new_scale.x * 100)

@onready var selected_comps_label = $"SelectedComp"
@onready var toggle_label = $"ToggleMode"

func multiple_selection_mode() -> void:
	for comp_scene in $ContentControl/TreeComps.get_children():
		var button = comp_scene.get_node("Button")
		# Ensure button exists and is visible
		if not button or not button.visible:
			continue
		# Convert global mouse position to button's local space, considering transforms
		var global_mouse_pos = get_viewport().get_mouse_position()
		var button_global_rect = button.get_global_rect()
		if button_global_rect.has_point(global_mouse_pos):
			button.toggle_mode = true
			# Add component to group when selected
			GlobalData.selected_components.add_component(comp_scene.component)
			GlobalData.selected_components.annihilation()
			## DEBUG
			selected_comps_label.text = "Selected Component = " + ", ".join(GlobalData.selected_components.get_all_component_names())
			toggle_label.text = "Toggle Mode = true"

func single_selection_mode() -> void:
	# Clear status
	for comp_scene in $ContentControl/TreeComps.get_children():
		var button = comp_scene.get_node("Button")
		if button:
			button.toggle_mode = false
			# Clear components and add component when selected
			GlobalData.selected_components.clear_all_components()
			## DEBUG
			selected_comps_label.text = "Selected Component = NULL"
			toggle_label.text = "Toggle Mode = false"
#endregion
#endregion 

# Refresh node status and position
func _on_refresh_button_pressed() -> void:
	if $"Scenes/BottomSlide".get_node("HBoxContainer/ViewButton").is_pressed():
		on_view_button_toggled()
	elif $"Scenes/BottomSlide".get_node("HBoxContainer/EtaButton").is_pressed():
		on_eta_button_toggled()
