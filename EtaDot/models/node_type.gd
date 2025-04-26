extends Node

class_name NodeType

var NodeName: String:
    set(value): set_node_name(value)
var SpritePath: String:
    set(value): set_sprite_path(value)
var ShortDesc: String
var LongDesc: String

func set_node_name(value: String) -> void:
    assert(value.length() <= 50, "Too long!!")
    NodeName = value

func set_sprite_path(value: String) -> void:
    if value and not FileAccess.file_exists(value):
        push_warning("Sprite not found: %s" % value)
    SpritePath = value
