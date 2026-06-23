extends Object
class_name BabyGodotUtils
## Utility functions for Baby Godot

## Gets the first child of the `parent` node that matches the type `type`. Pass in the type directly instead of as a string.
static func get_first_child_of_type(parent: Node, type):
	var flat_children = parent.find_children("*")
	var index: int = flat_children.find_custom(func(child):
		return is_instance_of(child, type)
	)
	if index != -1:
		return flat_children[index]
	return null
