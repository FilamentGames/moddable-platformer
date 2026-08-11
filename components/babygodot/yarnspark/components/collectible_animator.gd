@tool
extends Node
class_name ScrollAnimator

## The path that contains the collectible yarnspark sprite
@export var yarnspark_node: Node

## The path that contains the uncollectible string sprite
@export var string_node: Node

## The animated sprite that plays animations
@export var animated_sprite: AnimatedSprite2D

## The animator for the collection animation
@export var animator: AnimationPlayer

## Emitted when the collect animation is done
signal collection_animation_finished

func _trigger_animation(condition_met: bool) -> void:
	yarnspark_node.hide()
	string_node.show()
	animated_sprite.play(_get_sprite_animation_name(condition_met))
	await animated_sprite.animation_finished
	yarnspark_node.visible = condition_met
	string_node.visible = not condition_met
	animated_sprite.play(&"default")

func _trigger_collection_animation() -> void:
	animator.play(&"collect")
	await animator.animation_finished
	collection_animation_finished.emit()

func _get_sprite_animation_name(condition_met: bool) -> StringName:
	return &"enable" if condition_met else &"disable"
