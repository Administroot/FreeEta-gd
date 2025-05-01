class_name LogUtil


static func info(msg: String) -> void:
    print_rich("[color=blue]【INFO】[/color] %s" % msg)

static func warning(msg: String) -> void:
    print_rich("[color=yellow]【WARNING】[/color] %s" % msg)

static func error(msg: String) -> void:
    print_rich("[color=red]【ERROR】[/color] %s" % msg)