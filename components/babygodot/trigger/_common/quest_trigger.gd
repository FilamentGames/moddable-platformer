extends Area2D
class_name QuestTrigger
## A trigger that detects the player, runs a function specified in the child behavior object, and then destroys itself.

## The behavior to run when the trigger is hit
@export var behavior: AbstractTriggerBehavior

## Whether or not to delete this object from the scene in editor when it has been triggered.
@export var delete_from_scene := false

func _player_entered() -> void:
	if behavior:
		behavior.run_trigger()
	if delete_from_scene:
		InGameQuestsBridge.delete_node_in_editor(self)
	queue_free()
