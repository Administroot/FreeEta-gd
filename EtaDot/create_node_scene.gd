extends PopupPanel

func _ready() -> void:
	var loaded_data: PlayerData = JsonClassConverter.json_file_to_class(NodeType, "user://saves/player_data.json", "your_secret_key") 
	if loaded_data:
		# ... Access properties of loaded_data ...
	else:
		print("Error loading player data.")