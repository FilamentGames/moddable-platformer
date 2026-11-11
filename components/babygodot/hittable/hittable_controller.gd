extends Node
class_name HittableController

@export var speed: float = 0.0

@export_group("External Refs")
@export var target: PhysicsBody2D

signal move_state_changed(active: bool)

var _is_active := false
var attack_sign := 1

func on_hit(p_attack_sign: int = 1) -> void:
	attack_sign = p_attack_sign
	target.velocity = _get_velocity()
	_is_active = true
	move_state_changed.emit(true)

func stop() -> void:
	_is_active = false
	target.velocity = Vector2(0, 0)
	move_state_changed.emit(false)
	if "use_gravity" in target:
			target.use_gravity = true

func _process(_delta: float) -> void:
	if _is_active:
		target.velocity = _get_velocity()

func _get_velocity() -> Vector2:
	return Vector2(speed * attack_sign, 0)
