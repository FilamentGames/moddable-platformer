extends Object
class_name UniqueSceneId
## Utility class for generating a "Unique Scene ID" for objects, allowing the continuity system to link an in-game object to its corresponding object in a scene file.

## What is used to separate the scene name from the object path
const delimeter := "%"

static func get_id(node: Node) -> String:
	var scene_path := node.owner.scene_file_path
	var node_path := str(node.owner.get_path_to(node))
	return scene_path + delimeter + node_path

static func find_by_id(scene: Node, unique_id: String) -> Node:
	var pieces := unique_id.split(delimeter)
	if pieces.size() < 2:
		return null
	var scene_path := pieces[0]
	var node_path := pieces[1]
	if scene.scene_file_path != scene_path:
		return null
	return scene.get_node_or_null(node_path)