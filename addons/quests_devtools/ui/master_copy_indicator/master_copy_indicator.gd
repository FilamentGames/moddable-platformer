@tool
extends Label
class_name MasterCopyIndicator
## A control displayed in the editor UI

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
		var master_copy := _add_master_level_lock_to_scene(scene)
		var clone_copy := _remove_master_level_lock_from_scene(scene)
		_locked = true
		ResourceSaver.save(master_copy, scene_path)
		_locked = false
		ResourceSaver.save(clone_copy, scene_path.replace(master_copy_directory, clone_copy_directory))

static func _add_master_level_lock_to_scene(scene: PackedScene) -> PackedScene:
	var root := scene.instantiate()
	var packed_scene := PackedScene.new()
	if not root.get_node_or_null("MasterLevelLock"):
		var lock := MasterLevelLock.new()
		lock.name = "MasterLevelLock"
		root.add_child(lock)
		lock.owner = root
		root.move_child(lock, 0)
	packed_scene.pack(root)
	root.free() # Clear up the temp scene memory
	return packed_scene

static func _remove_master_level_lock_from_scene(scene: PackedScene) -> PackedScene:
	var root := scene.instantiate()
	var packed_scene := PackedScene.new()
	var lock := root.get_node_or_null("MasterLevelLock")
	if lock:
		root.remove_child(lock)
		lock.free()
	packed_scene.pack(root)
	root.free() # Clear up the temp scene memory
	return packed_scene
