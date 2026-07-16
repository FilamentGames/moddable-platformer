extends Node2D

## Which component of the editor is unlocked by a powerup.
enum EditorUnlock {
	Inspector, ## The inspector panel
	SceneTree ## The scene tree panel
}

## The component of the editor that is unlocked by the powerup.
@export var editor_unlock: EditorUnlock = EditorUnlock.Inspector

func on_collect() -> void:
	match editor_unlock:
		EditorUnlock.Inspector:
			InGameQuestsBridge.set_inspector_dock_visible(true)
		EditorUnlock.SceneTree:
			InGameQuestsBridge.set_scene_tree_dock_visible(true)
		_:
			print("Unknown editor unlock")
	InGameQuestsBridge.delete_node_in_editor(self)
	queue_free()
