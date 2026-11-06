extends RefCounted
class_name FakeEditorInterface

var scene_root: Node

var edited_nodes: Array[Node] = []
var saved_scene_calls: int = 0

func get_edited_scene_root() -> Node:
	return scene_root

func edit_node(node: Node) -> void:
	edited_nodes.append(node)

func save_scene() -> void:
	saved_scene_calls += 1
