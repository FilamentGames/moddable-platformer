extends RefCounted
class_name NodeSerializer
## Helps serialize nodes into JSON

## Props that are skipped because they are fully computed from other values we're serializing
const skipped_values: Array = ["position", "rotation", "scale", "skew", "rotation_degrees", "global_position", "global_rotation", "global_rotation_degrees", "global_scale", "global_skew", "global_transform"]

## List of cached prototypes used for reference copies of prefabs
var _prototypes: Dictionary = {}

const _TYPED_VALUE_KEY := "$"

## Decorates a value with a type annotation that can be JSON-serialized
func _typed(prop: Variant, value: Variant, type_string_override: String = "") -> Dictionary:
	var type = type_string(typeof(prop)) if type_string_override.is_empty() else type_string_override
	return {"$type": type, _TYPED_VALUE_KEY: value}

## Returns true if a property should be serialized or if it's identical to the base prefab.
func _property_is_changed(node: Node, reference_copy: Node, propname: String) -> bool:
	if reference_copy.get(propname) is Node:
		return reference_copy.get_path_to(reference_copy.get(propname)) != node.get_path_to(node.get(propname))
	return reference_copy.get(propname) != node.get(propname)

## Serializes a property value
func _serialize_prop(prop: Variant):
	if prop is Transform2D:
		return _typed(prop, [prop.x.x, prop.x.y, prop.y.x, prop.y.y, prop.origin.x, prop.origin.y])
	elif prop is Vector2 or prop is Vector2i:
		return _typed(prop, [prop.x, prop.y])
	elif prop is Vector3 or prop is Vector3i:
		return _typed(prop, [prop.x, prop.y, prop.z])
	elif prop is Color:
		return _typed(prop, [prop.r, prop.g, prop.b, prop.a])
	elif prop is Rect2 or prop is Rect2i:
		return _typed(prop, [prop.position.x, prop.position.y, prop.size.x, prop.size.y])
	elif prop is Array:
		return _typed(prop, prop.map(func(item: Variant) -> Variant: return _serialize_prop(item)))
	elif prop is Dictionary:
		var out: Dictionary = {}
		for key in prop:
			out[key] = _serialize_prop(prop[key])
		return _typed(prop, out)
	elif prop is PackedScene:
		return _typed(prop, prop.resource_path, "PackedScene")
	return prop

## Deserializes a property that was previously decorated with `_typed`
func _deserialize_typed(prop: Dictionary, dest: Variant) -> Variant:
	var value = prop[_TYPED_VALUE_KEY]
	match prop["$type"]:
		"Transform2D":
			var out_transform: Transform2D
			out_transform.x.x = value[0]
			out_transform.x.y = value[1]
			out_transform.y.x = value[2]
			out_transform.y.y = value[3]
			out_transform.origin.x = value[4]
			out_transform.origin.y = value[5]
			return out_transform
		"Vector2":
			return Vector2(value[0], value[1])
		"Vector2i":
			return Vector2i(int(value[0]), int(value[1]))
		"Vector3":
			return Vector3(value[0], value[1], value[2])
		"Vector3i":
			return Vector3i(int(value[0]), int(value[1]), int(value[2]))
		"Color":
			var out_color: Color
			out_color.r = value[0]
			out_color.g = value[1]
			out_color.b = value[2]
			out_color.a = value[3]
			return out_color
		"Rect2":
			return Rect2(value[0], value[1], value[2], value[3])
		"Rect2i":
			return Rect2i(int(value[0]), int(value[1]), int(value[2]), int(value[3]))
		"Array":
			var out_array: Array = []
			var dest_array: Array = dest if dest is Array else []
			for i in value.size():
				var dest_elem: Variant = null
				if i < dest_array.size():
					dest_elem = dest_array[i]
				out_array.append(_deserialize_prop(value[i], dest_elem))
			return out_array
		"Dictionary":
			var out_dict: Dictionary = {}
			var dest_dict: Dictionary = dest if dest is Dictionary else {}
			for key in value:
				var dest_value: Variant = null
				if dest_dict.has(key):
					dest_value = dest_dict[key]
				out_dict[key] = _deserialize_prop(value[key], dest_value)
			return out_dict
		"PackedScene":
			return load(value)
	push_error("Unknown typed value: " + str(prop["$type"]))
	return prop

## Deserializes a prop serialized with _serialize_prop
func _deserialize_prop(prop: Variant, dest: Variant) -> Variant:
	if prop is Dictionary and prop.has("$type"):
		return _deserialize_typed(prop, dest)
	return prop

## Fetches a prototype of a prefab, or instantiates a new one if it doesn't exist
func _get_prototype_of(prefab_path: String) -> Node:
	if _prototypes.has(prefab_path):
		return _prototypes[prefab_path]
	var reference_copy = load(prefab_path).instantiate()
	_prototypes[prefab_path] = reference_copy
	return reference_copy

## Get children of a node that aren't part of its prefab
func _get_unique_children(node: Node, reference_copy: Node) -> Array[Node]:
	var reference_children = reference_copy.get_children().map(func(child: Node):
		return reference_copy.get_path_to(child)
	)
	return node.get_children().map(func(child: Node):
		return node.get_path_to(child)
	).filter(func(path: NodePath):
		return not reference_children.has(path)
	).map(func(path: NodePath):
		return node.get_node(path)
	)

## Clear out the cached prefab prototypes. Useful for not creating orphans during tests.
func clear() -> void:
	for prefab in _prototypes.keys():
		_prototypes[prefab].free()
	_prototypes.clear()

## Serializes a Node into a JSON-stringifiable Dictionary object. [br]
## Note: This only works on nodes that are instantiated from a prefab.
func serialize(node: Node) -> Dictionary:
	if node.scene_file_path:
		var props = {
			"$name": node.name,
			"$prefab": node.scene_file_path
		}
		var reference_copy = _get_prototype_of(node.scene_file_path)
		var unique_children = _get_unique_children(node, reference_copy).map(func(child: Node):
			return serialize(child)
		).filter(func(serialized: Dictionary):
			return not serialized.keys().is_empty()
		)
		if not unique_children.is_empty():
			props["$children"] = unique_children
		for prop in node.get_property_list():
			var propname = prop["name"]
			if skipped_values.has(propname):
				continue
			if _property_is_changed(node, reference_copy, propname):
				if node.get(propname) is Node:
					props[propname] = str(node.get_path_to(node.get(propname)))
				else:
					props[propname] = _serialize_prop(node.get(propname))
		return props
	push_error("Edge case hit: Can't serialize a non-prefab object right now!")
	return {}

## Deserializes a node previously serialized with `serialize`
func deserialize(dict: Dictionary, new_parent: Node = null) -> Node:
	var new_node: Node = load(dict["$prefab"]).instantiate()
	new_node.name = dict["$name"]
	if new_parent:
		new_parent.add_child(new_node)
		new_node.owner = new_parent
	for key: String in dict.keys():
		if not key.begins_with("$"):
			if new_node.get(key) is Node and new_parent:
				new_node.set(key, new_node.get_node(dict[key]))
			else:
				new_node.set(key, _deserialize_prop(dict[key], new_node.get(key)))
	if dict.has("$children"):
		for child in dict["$children"]:
			deserialize(child, new_node)
	return new_node
