extends PopupPanel

@export var choice: bool

func _on_confirm_button_pressed() -> void:
	choice = true
	queue_free()


func _on_cancel_button_pressed() -> void:
	choice = false
	queue_free()


func _on_select_button_pressed() -> void:
	$"VBoxContainer/HBox/FileDialog".show()

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	# If image cannot load
	if image.load(path):
		var error = "Load picture from {path} failed!"
		LogUtil.error_dialog($".", error.format({"path": path}))
		return
	
	# If [image size](`Vector 2i`) is too big
	var texture = ImageTexture.create_from_image(image)
	if image.get_size() > Vector2i($"VBoxContainer/VBox".size):
		LogUtil.error_dialog($".", "Your picture is too big!")
		return
	
	$"VBoxContainer/VBox/NodeTexture".texture = texture
	LogUtil.info("Load picture from %s" % path)
