class_name LogUtil


static func info(msg: String) -> void:
    print_rich("[color=blue]【INFO】[/color] %s" % msg)

static func warning(msg: String) -> void:
    print_rich("[color=yellow]【WARNING】[/color] %s" % msg)

static func error(msg: String) -> void:
    print_rich("[color=red]【ERROR】[/color] %s" % msg)

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