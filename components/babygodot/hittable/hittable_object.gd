extends CharacterBody2D
class_name HittableObject

## Whether this object is hittable by the player's sword or not.
@export var hittable: bool = false

signal hit(attack_sign: int)
signal _do_hit(attack_sign: int)
signal hit_wall

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var use_gravity := true

var _reset_on_unpause: ResetOnUnpause

func _ready() -> void:
	if not _reset_on_unpause:
		_reset_on_unpause = ResetOnUnpause.new(self)
	_reset_on_unpause.on_reset.connect(func():
		hit_wall.emit()
	)

func _physics_process(_delta: float) -> void:
	if use_gravity:
		velocity.y = gravity
	move_and_slide()

	if is_on_wall():
		hit_wall.emit()

func _on_hit(attack_sign: int) -> void:
	if hittable:
		_do_hit.emit(attack_sign)
