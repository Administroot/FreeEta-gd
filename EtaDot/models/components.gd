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

func get_name_by_nodeid(node_id: int) -> String:
    for component in components:
        if component.node_id == node_id:
            return component.node_name
    return ""

func update_component(component: Component) -> void:
    for index in range(len(components)):
        if components[index].node_id == component.node_id:
            # Update old node
            components[index] = component
            return
    # Append new node
    components.append(component)

func clear_all_components() -> void:
    components.clear()

func get_components_id() -> Array[int]:
    var ids: Array[int] = []
    for component in components:
        ids.append(component.node_id)
    return ids

func get_all_component_names() -> Array[String]:
    var names: Array[String] = []
    for component in components:
        names.append(component.node_name)
    return names

func get_all_component_ids() -> Array[int]:
    var ids: Array[int] = []
    for component in components:
        ids.append(component.node_id)
    return ids

func print_all_members(components_name: String) -> void:
    LogUtil.info("-".repeat(50))
    LogUtil.info("%s includes:" % components_name)
    for component in components:
        component.printall()
    LogUtil.info("-".repeat(50))