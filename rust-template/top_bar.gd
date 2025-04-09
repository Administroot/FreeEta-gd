extends MenuBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. 加载主题文件
	var theme = load("res://themes/TopBarTheme.tres")
	# var theme = $TopBar.Theme
	if theme == null:
		push_error("主题文件加载失败")
		return
	# 2. 获取字体大小
	var target_control = "PopupMenu"  # 目标控件类型
	if theme.has_constant("font_size", target_control):
		var font_size = theme.get_constant("font_size", target_control)
		print("%s 的字体大小: %d" % [target_control, font_size])
	else:
		push_error("主题中未定义 'font_size' 常量")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
