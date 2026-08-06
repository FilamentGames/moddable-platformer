@tool
extends Node2D
class_name CollectibleGateLantern
## Lantern that is lit at collectible gates

## The texture for the lantern front
@export var lantern_front_texture: Texture2D = preload("res://components/babygodot/scroll_gate/assets/LanternLeft_Front.png")

@export_group("Internal Refs")
@export var lantern_front: Sprite2D

@export var animator: AnimationPlayer

signal updated(lit: bool)

var _lit: bool = false

## Whether the lantern is lit or not
var lit: bool:
	get:
		return _lit
	set(value):
		_lit = value
		updated.emit(_lit)
		if _lit and animator:
			animator.play(&"lighting")

func _ready() -> void:
	if lantern_front:
		lantern_front.texture = lantern_front_texture
