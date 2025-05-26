extends Node

class_name NodeType

@export var type_name: String = ""
@export var sprite_path: String = ""
@export var short_desc: String = ""
@export var long_desc: String = ""

func print_all_members() -> void:
    print_rich("[color=orange]&&&&&[/color] type_name: %s || sprite_path: %s || short_desc: %s || long_desc: %s [color=orange]&&&&&[/color]" % [type_name, sprite_path, short_desc, long_desc])