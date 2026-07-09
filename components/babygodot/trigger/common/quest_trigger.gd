extends Area2D
class_name QuestTrigger
## A trigger that detects the player, runs a function specified in the child behavior object, and then destroys itself.

## The behavior to run when the trigger is hit
@export var behavior: AbstractTriggerBehavior

func _player_entered() -> void:
	if behavior:
		behavior.run_trigger()
	queue_free()
