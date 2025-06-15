class_name LogUtil


static func info(msg: String) -> void:
	var logger = "[color=blue]「INFO」[/color] {msg}".format({"msg": msg})
	print_rich(logger)
	write_to_log(logger)

static func warning(msg: String) -> void:
	var logger = "[color=yellow]「WARNING」[/color] {msg}".format({"msg": msg})
	print_rich(logger)
	write_to_log(logger)

static func error(msg: String) -> void:
	var logger = "[color=red]「ERROR」[/color] {msg}".format({"msg": msg})
	print_rich(logger.format({"msg": msg}))
	write_to_log(logger)

static func error_dialog(node: Node, msg: String) -> void:
	var dialog = preload("res://error_dialog.tscn").instantiate()
	dialog.msg = msg
	node.add_child(dialog)
	await dialog.tree_exited
	LogUtil.error(msg)

static func warning_dialog(node: Node, msg: String) -> void:
	var dialog = preload("res://alert_dialog.tscn").instantiate()
	dialog.msg = msg
	node.add_child(dialog)
	await dialog.tree_exited
	LogUtil.warning(msg)

static func write_to_log(msg: String) -> void:
	msg = convert_bbcode(msg)
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "{year}-{month}-{day}".format(datetime)
	var file_path = "user://FreeEta-" + timestamp + ".log"
	var file: FileAccess
	if not FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.WRITE)
	else:
		file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(msg)
	file.close()

# TODO: Why RegEx Failed
# static var color_regex = RegEx.new()
# func _ready():
# 	color_regex.compile("/\\[.*\\]/Um")

static func convert_bbcode(code: String) -> String:
	var text = code
	text = text.replace("[color=orange]", "")
	text = text.replace("[color=blue]", "")
	text = text.replace("[color=pink]", "")
	text = text.replace("[color=red]", "")
	text = text.replace("[color=yellow]", "")
	text = text.replace("[/color]", "")
	text = text.replace("[b]", "")
	text = text.replace("[/b]", "")
	text += "\n\r"
	return text
