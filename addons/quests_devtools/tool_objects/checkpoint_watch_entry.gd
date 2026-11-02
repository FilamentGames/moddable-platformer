extends Resource
class_name CheckpointWatchEntry
## Represents an entry in the CheckpointDataHelper's list

## The node
@export var node: NodePath

## Nodes that should be updated first before this one is updated.
@export var dependencies: Array

static func create(n: Node, deps: Array[Node] = []) -> CheckpointWatchEntry:
	var entry = CheckpointWatchEntry.new()
	entry.node = trim_parent(BabyGodotUtils.get_node_path(n))
	entry.dependencies = deps.map(func(obj):
		return trim_parent(BabyGodotUtils.get_node_path(obj))
	)
	return entry

static func trim_parent(path: String) -> String:
	var path_pieces = path.split("/")
	return "/".join(path_pieces.slice(1))
