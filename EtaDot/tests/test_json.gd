extends GutTest

func test_load_json() -> void:
	var loaded_data: NodeTypes = JsonClassConverter.json_file_to_class(NodeTypes, "user://saves/node_types.json") 
	if loaded_data:
		assert_eq(loaded_data.get_type(0).type_name, "Pump")
	else:
		fail_test("Error loading node data.")


func test_write_to_json() -> void:
	# Pump equipment data
	var pump_data = NodeType.new()
	pump_data.type_name = "Pump"
	pump_data.sprite_path = "res://assets/pump.svg"
	pump_data.short_desc = "Centrifugal fluid transfer device"
	pump_data.long_desc = """\
	Standard industrial centrifugal pump
	- Max flow rate: 120 m³/h
	- Working pressure: 1.6 MPa
	- Compatible media: Water/Oil
	- Protection class: IP55
	Supports variable frequency control and remote monitoring"""

	# Valve equipment data
	var valve_data = NodeType.new()
	valve_data.type_name = "4-Way Ball Valve"
	valve_data.sprite_path = "res://assets/valve.svg"
	valve_data.short_desc = "Stainless steel control valve"
	valve_data.long_desc = """\
	316L stainless steel quarter-turn valve
	- Nominal diameter: DN50
	- Temperature range: -20°C to 180°C
	- Connection type: Flange
	- Seal material: PTFE
	Supports both actuator and manual operation modes"""

	var node_types = NodeTypes.new()
	node_types.add_type(pump_data)
	node_types.add_type(valve_data)

	var json_data = JsonClassConverter.class_to_json(node_types)

	var file_success: bool = JsonClassConverter.store_json_file("user://saves/node_types.json", json_data)

	# Check if saving was successful:
	if file_success:
		print("Node types saved successfully!")
	else:
		print("Error saving node types.") 

	assert_eq(file_success, true)