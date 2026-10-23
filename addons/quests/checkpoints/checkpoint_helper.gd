@tool
extends RefCounted
class_name CheckpointHelper
## Has checkpoint helper functions so that the `main.gd` file is not gigantic

const checkpoint_resource: String = "res://.temp/LastCheckpoint.tscn"

var saved_checkpoint_scene: PackedScene

## A reference to the undo/redo system so the user can undo the checkpoint load
var undo_redo

var _duplicated_roots: Array[Node] = []

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

func _init(editor_interface_inject = EditorInterface):
	editor_interface = EditorInterfaceProvider.new(editor_interface_inject)
	
## Saves the current editor scene as the new checkpoint
func save_editor_scene_as_checkpoint() -> void:
	if saved_checkpoint_scene:
		saved_checkpoint_scene.free()
	var scene_root = editor_interface.get_edited_scene_root()
	saved_checkpoint_scene = PackedScene.new()
	saved_checkpoint_scene.pack(scene_root)

## Loads the current checkpoint into the current editor scene
func set_editor_scene() -> void:
	if not saved_checkpoint_scene:
		return
	var scene_root = editor_interface.get_edited_scene_root().duplicate(Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SIGNALS)
	var root = saved_checkpoint_scene.instantiate()

	_setup_undo_redo(root, scene_root)

	_duplicated_roots.append(scene_root)
	_duplicated_roots.append(root)

## Sets up the undo/redo action so that a checkpoint load can be undone
func _setup_undo_redo(root: Node, scene_root: Node) -> void:
	undo_redo.create_action("Restore Checkpoint")
	undo_redo.add_do_method(self, &"_do_replace_root", root)
	undo_redo.add_undo_method(self, &"_do_replace_root", scene_root)
	undo_redo.commit_action()

## Updates the `owner` field of each child in a node recursively IF the node's original parent was the root of its original scene.
func _recursive_set_node_owner(node: Node, old_root: Node, owner: Node) -> void:
	if node.get_children().size() == 0:
		if node.owner == old_root:
			node.owner = owner
	else:
		for child in node.get_children():
			_recursive_set_node_owner(child, old_root, owner)
		if node.owner == old_root:
			node.owner = owner

## Removes the children in the current scene, adds the new children to the editor scene, and updates their ownership
func _do_replace_root(new_node: Node) -> void:
	var scene_root = editor_interface.get_edited_scene_root()

	for child in scene_root.get_children():
		scene_root.remove_child(child)
		child.free()
	
	for child in new_node.get_children():
		child.owner = null
		new_node.remove_child(child)
		scene_root.add_child(child)
		_recursive_set_node_owner(child, new_node, scene_root)
		child.owner = scene_root
	
	editor_interface.edit_node(new_node)

	if Engine.is_editor_hint(): ## This doesn't work in tests, but is needed in production
		new_node.owner = scene_root

	editor_interface.save_scene()
