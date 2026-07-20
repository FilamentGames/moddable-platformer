extends Object
class_name BabyGodotUtils
## Utility functions for Baby Godot

## Gets the first child of the `parent` node that matches the type `type`. Pass in the type directly instead of as a string.
static func get_first_child_of_type(parent: Node, type):
	var flat_children = parent.find_children("*")
	var index := flat_children.find_custom(func(child):
		return is_instance_of(child, type)
	)
	if index != -1:
		return flat_children[index]
	return null

static func get_all_children_of_type(parent: Node, type) -> Array[Node]:
	var flat_children = parent.find_children("*")
	var children: Array[Node] = []
	for child in flat_children:
		if is_instance_of(child, type):
			children.push_back(child)
	return children

## Obtain a reference to a dock object exclusive to the Streamlined editor
static func _get_streamlined_exclusive_dock(name: StringName):
	var interface = EditorInterface
	if interface.has_method(name):
		return interface.call(name)
	else:
		return null

## Toggle the visibility of a dock we only have access to in the streamlined editor.[br]
## Example: `toggle_streamlined_exclusive_dock("get_inspector_dock", false)`
static func toggle_streamlined_exclusive_dock(name: StringName, visible: bool) -> void:
	var dock: EditorDock = _get_streamlined_exclusive_dock(name)
	if dock:
		dock.open() if visible else dock.close()
	else:
		# Print a message to the output window so we know it would have worked in streamlined Godot
		var verb := "open" if visible else "close"
		print("Tried to " + verb + " the dock via `" + name + "` but it's not possible in this version of Godot!")