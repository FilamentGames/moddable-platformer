@tool
extends Object
class_name CheckpointHelper
## Has checkpoint helper functions so that the `main.gd` file is not gigantic

const checkpoint_resource: String = "res://.temp/LastCheckpoint.tscn"

## A reference to our main editor plugin so we can call fancy editor methods
var plugin: EditorPlugin

## Saves the current editor scene as the new checkpoint
func save_editor_scene_as_checkpoint() -> void:
	var scene_root = EditorInterface.get_edited_scene_root()
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene_root)
	ResourceSaver.save(packed_scene, checkpoint_resource)

## Loads the current checkpoint into the current editor scene
func set_editor_scene() -> void:
	var scene_root = EditorInterface.get_edited_scene_root().duplicate()
	var root = load(checkpoint_resource).instantiate()

	_setup_undo_redo(root, scene_root)

## Sets up the undo/redo action so that a checkpoint load can be undone
func _setup_undo_redo(root: Node, scene_root: Node) -> void:
	var undo_redo = plugin.get_undo_redo()

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
	var scene_root = EditorInterface.get_edited_scene_root()

	for child in scene_root.get_children():
		scene_root.remove_child(child)
	
	for child in new_node.get_children():
		new_node.remove_child(child)
		scene_root.add_child(child)
		_recursive_set_node_owner(child, new_node, scene_root)
	
	EditorInterface.edit_node(new_node)
	new_node.owner = scene_root

	EditorInterface.save_scene()
