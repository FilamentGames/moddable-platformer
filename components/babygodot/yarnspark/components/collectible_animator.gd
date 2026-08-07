@tool
extends Node
class_name ScrollAnimator

## The sprite to show
@export var animator: AnimationPlayer

func _trigger_animation(condition_met: bool) -> void:
	animator.play(_get_animation_name(condition_met))

func _get_animation_name(condition_met: bool) -> StringName:
	if condition_met:
		return &"activate_scroll"
	return &"deactivate_scroll"
