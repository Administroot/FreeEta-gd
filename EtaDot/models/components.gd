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

func print_all_members(components_name: String) -> void:
    LogUtil.info("-".repeat(50))
    LogUtil.info("%s includes:" % components_name)
    for component in components:
        print_rich("[color=pink]&&&&&[/color] node_id: %s || node_name: %s || node_type: %s || reliability: %s || prev_node: %s [color=orange]&&&&&[/color]" % [component.node_id, component.node_name, component.node_type, component.reliability, component.prev_node])
    LogUtil.info("-".repeat(50))