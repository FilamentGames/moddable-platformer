@tool
extends Label
class_name MasterCopyIndicator
## A control displayed in the editor UI

## A dev tools setting that adds the Player to the editable nodes list on clones automatically. This is useful for quickly testing changes to the player, while not actually saving the changes to the master copy.
static var add_player_to_editable_nodes := false

## Used for not getting stuck in an endless loop when re-saving the master copy.
var _locked := false

## Where master copies are stored in the project
var master_copy_directory := "res://levels/masters/"

## Where clone copies are stored in the project
var clone_copy_directory := "res://levels/clones/"

## This is run when the current scene changes
func scene_changed(scene_path: String) -> void:
	visible = scene_path.begins_with(master_copy_directory)

func scene_saved(scene_path: String) -> void:
	if _locked:
		return
	if scene_path.begins_with(master_copy_directory):
		var scene: PackedScene = load(scene_path)
		var root: Node = scene.instantiate()
		var master_copy := _get_master_copy_scene(scene)
		var clone_copy := _get_clone_copy_scene(scene)
		_locked = true
		ResourceSaver.save(master_copy, scene_path)
		_locked = false
		ResourceSaver.save(clone_copy, scene_path.replace(master_copy_directory, clone_copy_directory))

static func _get_master_copy_scene(scene: PackedScene) -> PackedScene:
	return _add_editable_node_list_to_scene(_add_master_level_lock_to_scene(scene))

static func _get_clone_copy_scene(scene: PackedScene) -> PackedScene:
	return _lock_uneditable_nodes(_remove_master_level_lock_from_scene(scene))

static func _add_master_level_lock_to_scene(scene: PackedScene) -> PackedScene:
	return _edit_scene(scene, func(root: Node):
		if not root.get_node_or_null("MasterLevelLock"):
			var lock := MasterLevelLock.new()
			lock.name = "MasterLevelLock"
			root.add_child(lock)
			lock.owner = root
			root.move_child(lock, 0)
	)

static func _remove_master_level_lock_from_scene(scene: PackedScene) -> PackedScene:
	return _edit_scene(scene, func(root: Node):
		var lock := root.get_node_or_null("MasterLevelLock")
		if lock:
			root.remove_child(lock)
			lock.free()
	)

static func _add_editable_node_list_to_scene(scene: PackedScene) -> PackedScene:
	return _edit_scene(scene, func(root: Node):
		if not root.get_node_or_null("EditableNodeList"):
			var editable_node_list := EditableNodeList.new()
			editable_node_list.name = "EditableNodeList"
			root.add_child(editable_node_list)
			editable_node_list.owner = root
			root.move_child(editable_node_list, 0)
	)

static func _lock_uneditable_nodes(scene: PackedScene) -> PackedScene:
	return _edit_scene(scene, func(root: Node):
		var editable_node_list := root.get_node_or_null("EditableNodeList")
		if MasterCopyIndicator.add_player_to_editable_nodes:
			var player: Node = BabyGodotUtils.get_first_child_of_type(root, Player)
			if player:
				editable_node_list.nodes.push_back(player)
		if editable_node_list and not editable_node_list.nodes.is_empty():
			## Lock all children by default
			var flat_children := root.find_children("*", "", true, false)
			for child in flat_children:
				child.set_meta("_edit_lock_", true)

			## Unlock the editable nodes. Their parents do not need to be unlocked.
			for node in editable_node_list.nodes:
				node.remove_meta("_edit_lock_")
				var editable_object_indicator := EditableObjectIndicator.new()
				editable_object_indicator.name = "EditableObjectIndicator"
				editable_object_indicator.set_meta("_edit_lock_", true)
				node.add_child(editable_object_indicator)
				editable_object_indicator.owner = root
	)

## Helper method to edit a packed scene and return a new packed scene with any changes made from the callable.
static func _edit_scene(scene: PackedScene, callable: Callable) -> PackedScene:
	var packed_scene := PackedScene.new()
	var root := scene.instantiate()
	callable.call(root)
	packed_scene.pack(root)
	root.free() # Clear up the temp scene memory
	return packed_scene