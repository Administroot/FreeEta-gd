extends Node

class_name NodeType

@export var type_name: String = ""
@export var sprite_path: String = ""
@export var short_desc: String = ""
@export var long_desc: String = ""

func print_all_members() -> void:
    var logger = "[color=orange]&&&&&[/color] type_name: {type_name} || sprite_path: {sprite_path} || short_desc: {short_desc} || long_desc: {long_desc} [color=orange]&&&&&[/color]".format({
        "type_name": type_name,
        "sprite_path": sprite_path,
        "short_desc": short_desc,
        "long_desc": long_desc
    })
    print_rich(logger)
    LogUtil.write_to_log(logger)