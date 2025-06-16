extends Node

class_name Component

@export var node_id: int = -1
@export var node_name: String = ""
@export var node_type: String = ""
@export var reliability: float = 0.0
@export var prev_node: PackedInt32Array

func printall() -> void:
    var logger = "[color=pink]&&&&&[/color] node_id: {node_id} || node_name: {node_name} || node_type: {node_type} || reliability: {reliability} || prev_node: {prev_node} [color=pink]&&&&&[/color]".format({"node_id": node_id, "node_name": node_name, "node_type": node_type, "reliability": reliability, "prev_node": prev_node})
    print_rich(logger)
    LogUtil.write_to_log(logger)

func get_nodetype_by_component() -> NodeType:
    return GlobalData.nodetypes_data.get_type_by_name(node_type)

func equal(other: Component) -> bool:
    if node_id != other.node_id:
        return false
    if node_name != other.node_name:
        return false
    if node_type != other.node_type:
        return false
    if reliability != other.reliability:
        return false
    if prev_node != other.prev_node:
        return false
    return true