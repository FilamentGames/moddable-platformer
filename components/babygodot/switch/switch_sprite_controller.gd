@tool
extends Node
class_name SwitchSpriteController
## Controls graphics for the Switch object

@export_group("Internal Refs")
@export var sprite: Sprite2D
@export var switch: Switch

func _ready() -> void:
	switch.on_toggle.connect(_on_switch)

func _on_switch(value: bool) -> void:
	sprite.frame = 1 if value else 0