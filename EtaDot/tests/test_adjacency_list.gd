extends GutTest

var components_data = get_components()

func create_adjacency_list() -> Dictionary:
	var component_graph = {}
	
	# Initialize graph with basic component info
	for comp in components_data.components:
		component_graph[comp.node_id
] = {
	"name": comp.node_name,
	"type": comp.node_type,
	"reliability": comp.reliability,
	"prev": comp.prev_node,
	"next": [] # Will be populated below
}
	
	# Populate the next nodes list
	for comp in components_data.components:
		# For each node that has this as prev, add this node to their prev's next list
		for prev_id in comp.prev_node:
			if prev_id != -1 and prev_id in component_graph:
				component_graph[prev_id
][
	"next"
].append(comp.node_id)
	
	return component_graph

func test_adjacency_list() -> void:
	var component_graph = {
		0: {
			"name": "Initial",
			"type": "Initial",
			"reliability": 1.0,
			"prev": [],
			"next": [1]
		},
		1: {
			"name": "Pump",
			"type": "Pump",
			"reliability": 0.98,
			"prev": [0],
			"next": [2]
		},
		2: {
			"name": "ValveA",
			"type": "Valve",
			"reliability": 0.95,
			"prev": [1],
			"next": [3, 4]
		},
		3: {
			"name": "ValveB",
			"type": "Valve",
			"reliability": 0.99,
			"prev": [2],
			"next": [5]
		},
		4: {
			"name": "ValveC",
			"type": "Valve",
			"reliability": 0.99,
			"prev": [2],
			"next": [5]
		},
		5: {
			"name": "ValveD",
			"type": "Valve",
			"reliability": 0.85,
			"prev": [3, 4], 
			"next": []
		}
	}
	var result_graph = create_adjacency_list()
	var component_graph_json = JSON.stringify(component_graph)
	var result_graph_json = JSON.stringify(result_graph)
	if component_graph_json == result_graph_json:
		LogUtil.info("Result Graph:")
		print(result_graph_json)
		LogUtil.info("Expected Graph:")
		print(component_graph_json)
	assert_eq(result_graph_json, component_graph_json)

# Get data from json
func get_components() -> Components:
	var loaded_data: Components = JsonClassConverter.json_file_to_class(Components,
"res://examples/saves/components.json")
	if !loaded_data:
		var msg = "Error loading [color=golden]Components[/color] data."
		LogUtil.error(msg)
		push_error(msg)
	return loaded_data
