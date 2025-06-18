extends Node2D


func _on_comps_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VSplit/CodeEdit.text = read_json_config("user://saves/components.json")


func _on_node_type_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VSplit/CodeEdit.text = read_json_config("user://saves/node_types.json")

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
