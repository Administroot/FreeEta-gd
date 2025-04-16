extends PopupPanel

func _ready():
	#var tree = $"WindowTypeSetting/SelectTab/Third-Party License/VBoxContainer/LicenseHSplit/ThirdPartyList"
	#tree.set_column_custom_minimum_width(0, 180)
	#var root = tree.create_item()
	#tree.hide_root = true
	#var godot = tree.create_item(root)
	#godot.set_text(0,"Godot")
	#var serde = tree.create_item(root)
	#serde.set_text(0,"Serde_Json")
	#var algor = tree.create_item(root)
	#algor.set_text(0,"algor")
	pass

func _on_icon_focus_entered() -> void:
	$WindowTypeSetting/SummaryInfo/Icon.flip_v = !$WindowTypeSetting/SummaryInfo/Icon.flip_v
