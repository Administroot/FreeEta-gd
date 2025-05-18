extends Node

@onready var components_data = get_components()

#region Boot Up
func _init() -> void:
	var dir = DirAccess.open("user://config")
	if dir == null:
		DirAccess.make_dir_absolute("user://config")
	check_config("node_types.json")
	check_config("components.json")

func check_config(config_name: String) -> void:
	if not FileAccess.file_exists("user://config/" + config_name):
		var source = FileAccess.open("res://examples/config/" + config_name, FileAccess.READ)
		var target = FileAccess.open("user://config/" + config_name, FileAccess.WRITE)
		target.store_string(source.get_as_text())
		source.close()
		target.close()
#endregion

#region CustomNodes
func _ready() -> void:
	# Connect signals from scene `BottomSlide`
	$"Scenes/BottomSlide".view_button_toggled.connect(on_view_button_toggled)
	$"Scenes/BottomSlide".eta_button_toggled.connect(on_eta_button_toggled)
	$"Scenes/BottomSlide".code_button_toggled.connect(on_code_button_toggled)
#endregion

#region View
func on_view_button_toggled() -> void:
	LogUtil.info("View button toggled")

#JSON Serialize and Deserialize
func get_components() -> Components:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components, "user://config/components.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]Components[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data
#endregion

#region ETA
func on_eta_button_toggled() -> void:
	components_data.print_all_members("Components")
	LogUtil.info("ETA button toggled")
#endregion

#region Code
func on_code_button_toggled() -> void:
	LogUtil.info("Code button toggled")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var new_node = load("res://component.tscn").instantiate()
		new_node.position = get_viewport().get_mouse_position()
		add_child(new_node)
#endregion
