@tool
extends Node
## Controls the initialization and state of the Knit Witch sprite

## The possible spriteframes data that can be loaded in
@export var spriteframe_sets: Array[SpriteFrames]

## The sprite to apply spriteframes to
@export var sprite: AnimatedSprite2D

var _random := RandomNumberGenerator.new()

func _ready() -> void:
	_random.seed = sprite.global_position.x
	## TODO: seed this with something so knit witch colors are constant
	sprite.sprite_frames = spriteframe_sets[_random.randi_range(0, spriteframe_sets.size() - 1)]
	if Engine.is_editor_hint():
		sprite.play(&"idle")
		return
	sprite.animation_finished.connect(_do_idle_animation)
	sprite.play(&"appear")

func _do_idle_animation() -> void:
	sprite.play(&"idle")
	sprite.animation_finished.disconnect(_do_idle_animation)
	queue_free()
