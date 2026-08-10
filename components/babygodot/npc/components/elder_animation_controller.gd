@tool
extends Node

## The list of animations to play in a row. Add more `celebration_loop` lines if you want the elder to celebrate even more.
@export var animation_sequence: Array[StringName] = [
	&"celebration_start",
	&"celebration_loop",
	&"celebration_loop",
	&"celebration_end",
]

## The sprite to animate
@export var sprite: AnimatedSprite2D

signal done()

func trigger_animation() -> void:
	for anim in animation_sequence:
		sprite.play(anim)
		await sprite.animation_finished
	sprite.play(&"default")
	done.emit()
