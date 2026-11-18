@tool
extends CollectibleCondition
class_name ParentChildRelationshipScrollCondition

@export var parent_node: Node
@export var child_node: Node

var _last_valid_label_text: String = "Error! This condition is not valid."

func get_label_text() -> String:
	if parent_node and child_node:
		_last_valid_label_text = "The " + highlight_text(child_node.name) + " node must be a child of the " + highlight_text(parent_node.name) + " node."
	return _last_valid_label_text

func is_condition_met() -> bool:
	if not parent_node or not child_node:
		return false
	return child_node.get_parent() == parent_node