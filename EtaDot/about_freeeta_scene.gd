extends PopupPanel

var item_contents = [
	"Godot License\n这是Godot引擎的许可证信息...",
	"Serde_json License\n这是Serde_json库的许可证信息...",
	"Tokio License\n这是Tokio库的许可证信息...",
]

func _on_license_itemlist_item_selected(index: int) -> void:
	var txt_label = $"WindowTypeSetting/SelectTab/Third-Party License/Third-PartyVContainer/LicenseHSplit/LicenseScroll/SpecificLicense"

	if index >= 0 and index < item_contents.size():
		print(item_contents[index])
		txt_label.text = item_contents[index]
	else:
		push_error("No License found")
