@tool
extends RefCounted
class_name CheckpointHelper
## Has checkpoint helper functions so that the `main.gd` file is not gigantic

class EditorInterfaceProvider extends RefCounted:
	## The actual editor interface, or maybe a mock, who knows!
	var interface

	func get_edited_scene_root() -> Node:
		return interface.get_edited_scene_root()
	
	func edit_node(node: Node) -> void:
		interface.edit_node(node)
	
	func save_scene() -> void:
		interface.save_scene()

	func _init(_interface) -> void:
		interface = _interface
		if not _interface:
			interface = EditorInterface

## A reference to the editor interface. Can be susbstituted for a double in automated tests.
var editor_interface: EditorInterfaceProvider

## A reference to the undo/redo system so the user can undo the checkpoint load
var undo_redo

var scene_delta := SceneDelta.new()

func _init(editor_interface_inject = EditorInterface):
	editor_interface = EditorInterfaceProvider.new(editor_interface_inject)
	
func _bind_editor_scene_to_scene_delta() -> void:
	scene_delta.bind_editor_scene(editor_interface.get_edited_scene_root())

## Saves the current editor scene as the new checkpoint
func save_editor_scene_as_checkpoint() -> void:
	_bind_editor_scene_to_scene_delta()
	scene_delta.take_snapshot_of_watched_objects()

func register_node_deleted(node: Node) -> void:
	scene_delta.register_node_deleted(node)

func register_node_added(node: Node) -> void:
	scene_delta.register_node_added(node)

func register_node_modified(node: Node, property: StringName, previous_value: Variant, new_value: Variant) -> void:
	scene_delta.register_node_modified(node, property, previous_value, new_value)

## Loads the current checkpoint into the current editor scene
func set_editor_scene() -> void:
	_bind_editor_scene_to_scene_delta()
	var do_dict = scene_delta.export()
	var undo_dict = scene_delta.invert_export(scene_delta.export())
	undo_redo.create_action("Restore Checkpoint")
	undo_redo.add_do_method(self, &"_do_checkpoint_commit", do_dict)
	undo_redo.add_undo_method(self, &"_do_checkpoint_commit", undo_dict)
	undo_redo.commit_action()

func _do_checkpoint_commit(scene_delta_dict: Dictionary) -> void:
	_bind_editor_scene_to_scene_delta()
	scene_delta.import(scene_delta_dict)
	scene_delta.reset_to_checkpoint()

## Exports the scene delta's contents as a JSON-friendly dictionary
func export() -> Dictionary:
	return scene_delta.export()

## Imports an exported dictionary into the scene delta
func import(dict: Dictionary) -> void:
	scene_delta.import(dict)