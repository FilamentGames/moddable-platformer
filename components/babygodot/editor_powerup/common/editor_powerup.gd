extends Node2D

## Which component of the editor is unlocked by a powerup.
enum EditorUnlock {
	Inspector, ## The inspector panel
	SceneTree ## The scene tree panel
}

@export_group("Internal Refs")
## The component of the editor that is unlocked by the powerup.
@export var editor_unlock: EditorUnlock = EditorUnlock.Inspector

## Dialogue to spawn when the player collects the powerup
@export var unlock_dialogue: Array[String] = []

## The collision area that triggers the collection event
@export var collision_area: Area2D

## Emitted when the powerup is collected
signal collected()

func on_collect() -> void:
	match editor_unlock:
		EditorUnlock.Inspector:
			InGameQuestsBridge.set_inspector_dock_visible(true)
		EditorUnlock.SceneTree:
			InGameQuestsBridge.set_scene_tree_dock_visible(true)
		_:
			print("Unknown editor unlock")
	InGameQuestsBridge.delete_node_in_editor(self)
	var player: Player = BabyGodotUtils.get_first_child_of_type(get_tree().current_scene, Player)
	player.control_locked = true
	collision_area.queue_free()
	collected.emit()

func on_collection_complete() -> void:
	queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"scroll_collect":
		if not unlock_dialogue.is_empty():
			var player_dialogue: PlayerDialogueComponent = BabyGodotUtils.get_first_child_of_type(get_tree().current_scene, PlayerDialogueComponent)
			if player_dialogue:
				player_dialogue.force_dialogue(unlock_dialogue)
		on_collection_complete()
