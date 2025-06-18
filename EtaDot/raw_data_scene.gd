extends Node2D

func _on_comps_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VSplit/CodeEdit.text = read_json_config("user://saves/components.json")


func _on_node_type_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VSplit/CodeEdit.text = read_json_config("user://saves/node_types.json")


func _on_save_button_pressed() -> void:
	var comps_button = $"VSplit/FileHBox/CompsButton"
	var node_types_button = $"VSplit/FileHBox/NodeTypeButton"
	var codeedit = $"VSplit/CodeEdit"
	if comps_button.pressed:
		write_json_config("user://saves/components.json", codeedit.text)
	elif node_types_button.pressed:
		write_json_config("user://saves/node_types.json", codeedit.text)

#region CRUD
func read_json_config(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var res: String
	if file:
		res = file.get_as_text()
		file.close()
	else :
		LogUtil.error("Cannot read config file from [color=yellow]%s[/color]" % path)
		res = "Cannot read config file from {name}".format({"name": path})
	return res

func write_json_config(path: String, content: String) -> void:
	# Check if content is valid JSON
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		LogUtil.error_dialog(get_parent().get_parent(),"Invalid JSON format: [color=red]%s at line %s[/color]" % [json.get_error_message(), json.get_error_line()])
		return
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
	else:
		LogUtil.error_dialog(get_parent().get_parent(), "Cannot write config file to [color=yellow]%s[/color]" % path)
#endregion
