extends Node

class_name Components

@export var components: Array[Component] = []

func add_component(node: Component) -> void:
    components.append(node)

func get_component(index: int) -> Component:
    return components[index]

func get_component_by_name(node_name: String) -> Component:
    for index in range(len(components)):
        if components[index].node_name == node_name:
            return components[index]
    return null

func get_component_by_nodeid(node_id: int) -> Component:
    for index in range(len(components)):
        if components[index].node_id == node_id:
            return components[index]
    return null

func print_all_members(components_name: String) -> void:
    LogUtil.info("-".repeat(50))
    LogUtil.info("%s includes:" % components_name)
    for component in components:
        component.printall()
    LogUtil.info("-".repeat(50))