extends RefCounted
class_name NodeSerializer
## Helps serialize nodes into JSON

## Props that are skipped because they are fully computed from other values we're serializing
const skipped_values: Array = ["position", "rotation", "scale", "skew", "rotation_degrees", "global_position", "global_rotation", "global_rotation_degrees", "global_scale", "global_skew", "global_transform", "owner", "multiplayer", "name", "scene_file_path"]

## List of cached prototypes used for reference copies of prefabs
var _prototypes: Dictionary = {}

const _TYPED_VALUE_KEY := "$"

## Decorates a value with a type annotation that can be JSON-serialized
func _typed(prop: Variant, value: Variant, type_string_override: String = "") -> Dictionary:
	var type = type_string(typeof(prop)) if type_string_override.is_empty() else type_string_override
	return {"$type": type, _TYPED_VALUE_KEY: value}

## Returns true if a property should be serialized or if it's identical to the base prefab.
func _property_is_changed(node: Node, reference_copy: Node, propname: String) -> bool:
	if not reference_copy:
		return true
	if reference_copy.get(propname) is Node:
		return reference_copy.get_path_to(reference_copy.get(propname)) != node.get_path_to(node.get(propname))
	return reference_copy.get(propname) != node.get(propname)

## Serializes a property value on [param owner_node].
func _serialize_prop(owner_node: Node, prop: Variant) -> Variant:
	if prop is Node:
		return _typed(prop, str(owner_node.get_path_to(prop)), "Node")
	elif prop is Transform2D:
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
		return _typed(prop, prop.map(func(item: Variant) -> Variant: return _serialize_prop(owner_node, item)))
	elif prop is Dictionary:
		var out: Dictionary = {}
		for key in prop:
			out[key] = _serialize_prop(owner_node, prop[key])
		return _typed(prop, out)
	elif prop is PackedByteArray:
		var arr: PackedByteArray = prop
		return _typed(prop, Marshalls.raw_to_base64(arr), "PackedByteArray")
	elif prop is PackedScene:
		return _typed(prop, prop.resource_path, "PackedScene")
	elif prop is Resource:
		if prop.resource_path.is_empty():
			push_warning("Cannot JSON-serialize Resource without a resource_path.")
			return null
		return _typed(prop, prop.resource_path, "Resource")
	return prop

## Deserializes a property that was previously decorated with `_typed`
func _deserialize_typed(owner_node: Node, prop: Dictionary, dest: Variant) -> Variant:
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
			var dest_array: Array = dest if dest is Array else []
			var out_array: Array = dest_array.duplicate() if dest is Array else []
			out_array.clear()
			for i in value.size():
				var dest_elem: Variant = null
				if i < dest_array.size():
					dest_elem = dest_array[i]
				out_array.append(_deserialize_prop(owner_node, value[i], dest_elem))
			return out_array
		"Dictionary":
			var out_dict: Dictionary = {}
			var dest_dict: Dictionary = dest if dest is Dictionary else {}
			for key in value:
				var dest_value: Variant = null
				if dest_dict.has(key):
					dest_value = dest_dict[key]
				out_dict[key] = _deserialize_prop(owner_node, value[key], dest_value)
			return out_dict
		"Node":
			var node_path := str(value)
			if node_path.is_empty():
				return null
			return owner_node.get_node_or_null(NodePath(node_path))
		"PackedByteArray":
			return Marshalls.base64_to_raw(value)
		"PackedScene", "Resource":
			return load(value)
	push_error("Unknown typed value: " + str(prop["$type"]))
	return prop

## Deserializes a prop serialized with _serialize_prop
func _deserialize_prop(owner_node: Node, prop: Variant, dest: Variant) -> Variant:
	if prop is Dictionary and prop.has("$type"):
		return _deserialize_typed(owner_node, prop, dest)
	return prop

## Fetches a prototype of a prefab, or instantiates a new one if it doesn't exist
func _get_prototype_of(prefab_path: String) -> Node:
	if _prototypes.has(prefab_path):
		return _prototypes[prefab_path]
	var reference_copy = load(prefab_path).instantiate() if prefab_path.begins_with("res://") else ClassDB.instantiate(prefab_path)
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

func _is_ignored_property(node: Node, propname: String) -> bool:
	return "CHECKPOINT_SYSTEM_IGNORED_PROPERTIES" in node and node.CHECKPOINT_SYSTEM_IGNORED_PROPERTIES.has(propname)

func _is_property_group_or_category(prop: Dictionary) -> bool:
	var usage: int = prop["usage"]
	return usage & PROPERTY_USAGE_GROUP or usage & PROPERTY_USAGE_CATEGORY

## Serializes a Node into a JSON-stringifiable Dictionary object. [br]
## Note: This only works on nodes that are instantiated from a prefab.
func serialize(node: Node) -> Dictionary:
	var props = {}
	var reference_copy: Node
	if node.scene_file_path:
		props = {
			"$name": node.name,
			"$prefab": node.scene_file_path
		}
		reference_copy = _get_prototype_of(node.scene_file_path)
		var unique_children = _get_unique_children(node, reference_copy).map(func(child: Node):
			return serialize(child)
		).filter(func(serialized: Dictionary):
			return not serialized.keys().is_empty()
		)
		if not unique_children.is_empty():
			props["$children"] = unique_children
	else:
		props = {
			"$name": node.name,
			"$type": node.get_class()
		}
		reference_copy = _get_prototype_of(node.get_class())
	for prop in node.get_property_list():
		if _is_property_group_or_category(prop):
			continue
		var propname: String = prop["name"]
		if propname.is_empty() or skipped_values.has(propname) or propname.begins_with("_") or _is_ignored_property(node, propname):
			continue
		if _property_is_changed(node, reference_copy, propname):
			props[propname] = _serialize_prop(node, node.get(propname))
	return props

func _get_reference_copy_for_dict(dict: Dictionary) -> Node:
	if dict.has("$prefab"):
		return _get_prototype_of(dict["$prefab"])
	if dict.has("$type"):
		return _get_prototype_of(dict["$type"])
	return null

func _reference_value_for_node(node: Node, reference_copy: Node, reference_value: Variant) -> Variant:
	if reference_value is Node:
		if not reference_value:
			return null
		var node_path := str(reference_copy.get_path_to(reference_value))
		if node_path.is_empty():
			return null
		return node.get_node_or_null(NodePath(node_path))
	if reference_value is PackedByteArray:
		return reference_value.duplicate()
	return reference_value

func _set_node_property(node: Node, propname: String, value: Variant) -> void:
	if node is TileMapLayer and propname == "tile_map_data" and value is PackedByteArray:
		node.set_tile_map_data_from_array(value)
		node.update_internals()
		return
	node.set(propname, value)

func _apply_property_from_reference(node: Node, reference_copy: Node, propname: String) -> void:
	var reference_value: Variant = reference_copy.get(propname)
	if reference_value is Node and reference_value and str(reference_copy.get_path_to(reference_value)).is_empty():
		return
	_set_node_property(node, propname, _reference_value_for_node(node, reference_copy, reference_value))

func _create_new_node(dict: Dictionary) -> Node:
	if dict.has("$prefab"):
		return load(dict["$prefab"]).instantiate()
	else:
		return ClassDB.instantiate(dict["$type"])

## Deserializes a node previously serialized with `serialize`
func deserialize(dict: Dictionary, new_parent: Node = null, new_owner = null) -> Node:
	var new_node: Node = _create_new_node(dict)
	new_node.name = dict["$name"]
	if new_parent:
		new_parent.add_child(new_node)
		new_node.owner = new_parent
	if new_owner:
		new_node.owner = new_owner
	deserialize_in_place(new_node, dict, new_parent)
	if dict.has("$children"):
		for child in dict["$children"]:
			deserialize(child, new_node, new_parent)
	if new_node.has_method("_on_checkpoint_reset"):
		new_node._on_checkpoint_reset.call_deferred()
	return new_node

func deserialize_in_place(node: Node, dict: Dictionary, _new_parent: Node = null) -> void:
	var reference_copy := _get_reference_copy_for_dict(dict)
	# Script must be applied before other exported props (e.g. typed Array[Node] fields).
	if dict.has("script"):
		_set_node_property(node, "script", _deserialize_prop(node, dict["script"], node.get("script")))
	for key: String in dict.keys():
		if key.begins_with("$") or key == "script":
			continue
		_set_node_property(node, key, _deserialize_prop(node, dict[key], node.get(key)))
	if not reference_copy:
		return
	for prop in node.get_property_list():
		if _is_property_group_or_category(prop):
			continue
		var propname: String = prop["name"]
		if propname.is_empty() or skipped_values.has(propname) or propname.begins_with("_") or _is_ignored_property(node, propname):
			continue
		if dict.has(propname):
			continue
		_apply_property_from_reference(node, reference_copy, propname)