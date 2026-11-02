extends RefCounted
class_name SceneDelta
## Tracks the changes made to a scene by the player.

var _editor_scene: Node

var _removed_nodes: Dictionary
var _watched_nodes: Dictionary
var _added_nodes: Array = []

var _watched_node_dependencies: Dictionary

var _serializer := NodeSerializer.new()

var _player_watcher: CheckpointPlayerWatcher


func bind_editor_scene(scene: Node) -> void:
	_editor_scene = scene
	if _player_watcher:
		_player_watcher._editor_scene = _editor_scene
	else:
		_player_watcher = CheckpointPlayerWatcher.new(_editor_scene)

func _delete() -> void:
	_serializer.clear()

func take_snapshot_of_watched_objects() -> void:
	_watched_nodes.clear()
	_added_nodes.clear()
	_removed_nodes.clear()
	_player_watcher.take_player_snapshot()
	var serialized_watch_nodes = _get_serialized_watched_nodes()
	_watched_node_dependencies = serialized_watch_nodes["dependencies"]
	_watched_nodes = serialized_watch_nodes["watch"]

func _get_serialized_watched_nodes() -> Dictionary:
	var out: Dictionary = {
		"watch": {},
		"dependencies": {}
	}
	var checkpoint_data_node: CheckpointDataHelper = BabyGodotUtils.get_first_child_of_type(_editor_scene, CheckpointDataHelper)
	for node in checkpoint_data_node.watched_nodes:
		var real_node = _editor_scene.get_node_or_null(node.node)
		if not real_node:
			continue
		out["watch"][_get_node_path(real_node)] = _serializer.serialize(real_node)
		out["dependencies"][node.node] = node.dependencies
	var editable_node_list: EditableNodeList = BabyGodotUtils.get_first_child_of_type(_editor_scene, EditableNodeList)
	for node in editable_node_list.nodes:
		if not node:
			continue
		if out.has(_get_node_path(node)):
			continue
		out["watch"][_get_node_path(node)] = _serializer.serialize(node)
	return out

func register_node_deleted(node: Node) -> void:
	_removed_nodes[_get_node_path(node)] = _serializer.serialize(node)

func register_node_added(node: Node) -> void:
	_added_nodes.push_back(_get_path_from_scene_root(_get_node_path(node)))

func _get_node_path(node: Node) -> String:
	return BabyGodotUtils.get_node_path(node, _editor_scene)

func _get_parent_path(path: String) -> String:
	var path_pieces = path.split("/")
	if path_pieces.size() <= 1:
		return ""
	return "/".join(path_pieces.slice(1, -1))

func _get_path_from_scene_root(path: String) -> String:
	var path_pieces = path.split("/")
	return "/".join(path_pieces.slice(1))

func _instantiate_removed_node(id: String, dict: Dictionary) -> void:
	var parent_id := _get_parent_path(id)
	var parent = _editor_scene if parent_id.is_empty() else _editor_scene.get_node(parent_id)
	_serializer.deserialize(dict, parent, _editor_scene)

func _get_watched_nodes_in_order() -> Array:
	var watched_node_graph := CheckpointDependencyGraph.new()
	for key in _watched_node_dependencies.keys():
		watched_node_graph.add_vertex(CheckpointDependencyGraph.Vertex.create(key))
	for key in _watched_node_dependencies.keys():
		for dependency in _watched_node_dependencies[key]:
			watched_node_graph.get_vertex(key).add_dependency(watched_node_graph.get_vertex(dependency))
	return watched_node_graph.get_sorted_values()

func reset_to_checkpoint() -> void:
	var _watched_nodes_in_order = _get_watched_nodes_in_order()
	for id: String in _watched_nodes_in_order:
		var full_path := _editor_scene.name + "/" + str(id)
		var node: Node = _editor_scene.get_node_or_null(id)
		if node:
			_serializer.deserialize_in_place(node, _watched_nodes[full_path])
		else:
			_instantiate_removed_node(full_path, _watched_nodes[full_path])
			if _removed_nodes.has(full_path):
				_removed_nodes.erase(_removed_nodes[full_path])
	for id: String in _removed_nodes.keys():
		_instantiate_removed_node(id, _removed_nodes[id])
	for id: String in _added_nodes:
		var node: Node = _editor_scene.get_node_or_null(id)
		node.get_parent().remove_child(node)
		node.queue_free()
	_player_watcher.apply_player_snapshot()
	_added_nodes.clear()
	_removed_nodes.clear()

func export() -> Dictionary:
	return {
		"added": _added_nodes,
		"watched": _watched_nodes,
		"removed": _removed_nodes,
		"player": _player_watcher.export()
	}

func import(dict: Dictionary) -> void:
	_added_nodes = dict["added"]
	_watched_nodes = dict["watched"]
	_removed_nodes = dict["removed"]
	_player_watcher.import(dict["player"])

func invert_export(dict: Dictionary) -> Dictionary:
	var removed = dict["removed"].duplicate()
	var added = dict["added"].duplicate()
	dict["removed"] = {}
	for path in added:
		var node: Node = _editor_scene.get_node_or_null(path)
		dict["removed"][path] = _serializer.serialize(node)
	dict["added"] = removed.keys().map(_get_path_from_scene_root)
	dict["watched"] = _get_serialized_watched_nodes()["watch"]
	dict["player"] = _player_watcher.get_player_position()
	return dict
