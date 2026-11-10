extends Node
class_name HittableController

@export var speed: float = 0.0

@export_group("External Refs")
@export var target: PhysicsBody2D

var _is_active := false
var attack_sign := 1

func on_hit(p_attack_sign: int = 1) -> void:
	target.velocity = Vector2(speed * p_attack_sign, 0)
	attack_sign = p_attack_sign
	_is_active = true

func stop() -> void:
	_is_active = false
	target.velocity = Vector2(0, 0)

func _process(_delta: float) -> void:
	if _is_active:
		target.velocity = Vector2(speed * attack_sign, 0)
