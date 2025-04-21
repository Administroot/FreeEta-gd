extends Node2D

func _ready() -> void:
	set_properties("res://assets/pump.svg")
	
func set_properties(picture: String) -> void:
	$Body/photo.texture = load(picture)
	var picture_size = $Body/photo.texture.get_size()
	$Body/CollisionShape.shape.size = picture_size
	$Body/Button.size = picture_size
	$Body/Button.position = - picture_size / 2.