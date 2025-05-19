extends GutTest

const error_msg = "Error loading node data."

func test_load_nodetypes() -> void:
	var loaded_data: NodeTypes = JsonClassConverter.json_file_to_class(NodeTypes, "res://examples/saves/node_types.json") 
	if loaded_data:
		assert_eq(loaded_data.get_type(0).type_name, "Pump")
	else:
		loaded_data.print_all_members("TEST:")
		fail_test(error_msg)

func test_load_components() -> void:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components, "res://examples/saves/components.json")
	if loaded_data:
		assert_eq(loaded_data.get_component(0).node_id, 1)
	else:
		loaded_data.print_all_members("TEST:")
		fail_test(error_msg)

func test_nodetypes_to_json() -> void:
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

	var file_success: bool = JsonClassConverter.store_json_file("user://tests/node_types.json", json_data)

	# Check if saving was successful:
	if file_success:
		print("Node types saved successfully!")
	else:
		print("Error saving node types.") 

	assert_eq(file_success, true)

func test_components_to_json() -> void:
	var comp1 = Component.new()
	comp1.node_id = 1
	comp1.node_name = "PumpA"
	comp1.node_type = "Pump"
	comp1.reliability = 0.98
	comp1.prev_node = [-1]

	var comp2 = Component.new()
	comp2.node_id = 2
	comp2.node_name = "ValveB"
	comp2.node_type = "Valve"
	comp2.reliability = 0.95
	comp2.prev_node = [1]
	
	var comp3 = Component.new()
	comp3.node_id = 3
	comp3.node_name = "SensorC"
	comp3.node_type = "Sensor"
	comp3.reliability = 0.99
	comp3.prev_node = [2]
	
	var components = Components.new()
	components.add_component(comp1)
	components.add_component(comp2)
	components.add_component(comp3)
	
	var json_data = JsonClassConverter.class_to_json(components)
	var file_success: bool = JsonClassConverter.store_json_file("user://tests/components.json", json_data)
	
	if file_success:
		print("Components saved successfully!")
	else:
		print("Error saving components.")
	
	assert_eq(file_success, true)