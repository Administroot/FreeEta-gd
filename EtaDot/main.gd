extends Control

#region Boot Up
func _init() -> void:
	# Check saves
	var dir = DirAccess.open("user://saves")
	if dir == null:
		DirAccess.make_dir_absolute("user://saves")
	check_saves("node_types.json")
	check_saves("components.json")
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
#endregion

#region TreeComps
func _ready() -> void:
	# Connect signals from scene `BottomSlide`
	$"Scenes/BottomSlide".view_button_toggled.connect(on_view_button_toggled)
	$"Scenes/BottomSlide".eta_button_toggled.connect(on_eta_button_toggled)
	$"Scenes/BottomSlide".code_button_toggled.connect(on_code_button_toggled)
	# Print GlobalData
	GlobalData.print_global_data()
#endregion

#region View
func on_view_button_toggled() -> void:
	clean_components()
	var scene = preload("res://CompTreeLayout.tscn").instantiate()
	scene.position = Vector2(90, 540)
	add_child(scene)

func clean_components() -> void:
	var tree_comps = $"TreeComps"
	if tree_comps:
		for child in tree_comps.get_children():
			child.queue_free()
#endregion

#region ETA
func on_eta_button_toggled() -> void:
	GlobalData.components_data.print_all_members("Components")
#endregion

#region Code
func on_code_button_toggled() -> void:
	pass
#endregion

#region Multiple Selection
var selection_mode = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_CTRL and event.pressed:
		selection_mode = true
		$"SelectedLabel".text = "NotSelected"
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_TAB:
			pass
	elif event is InputEventMouseButton and selection_mode == true:
		# CTRL + LEFT_CLICK Selected
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			multiple_selection_mode(event)
			$"SelectedLabel".text = "Selected"
	elif event is InputEventMouseMotion:
		$"SelectedLabel".text = "NotSelected"
		pass
	else :
		single_selection_mode()
		$"SelectedLabel".text = "NotSelected"
		selection_mode = false

	$"SelectionLabel".text = "selection_mode = {status}".format({"status": selection_mode})

func multiple_selection_mode(event: InputEvent) -> void:
	var clicked_pos = event.position
	for comp_scene in $TreeComps.get_children():
		var button = comp_scene.get_node("Button")
		if button.get_rect().has_point(clicked_pos - comp_scene.position):
			if button:
				button.toggle_mode = true
				# Add component to group when selected
				GlobalData.selected_components.add_component(comp_scene.component)

func single_selection_mode() -> void:
	# Clear status
	for comp_scene in $TreeComps.get_children():
		var button = comp_scene.get_node("Button")
		if button:
			button.toggle_mode = false
			# Clear components and add component when selected
			GlobalData.selected_components.clear_all_components()
#endregion 
