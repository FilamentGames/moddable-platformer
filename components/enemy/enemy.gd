class_name Enemy
extends CharacterBody2D

## How fast does your enemy move?
@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 100.0:
	set = _set_speed

## Does the enemy fall off edges?
@export var fall_off_edge: bool = false

## Does the player lose a life when contacting the enemy?
@export var player_loses_life: bool = true

## Can the enemy be squashed by the player?
@export var squashable: bool = true

## How much is the enemy flung horizontally when defeated? This value is multiplied by the enemy's standard speed.
@export_range(1.0, 10.0, 0.1, "suffix:x") var defeated_x_velocity_multiplier: float = 2.0

## How much is the enemy flung into the air when defeated? (Note: This value is multiplied by -1 to actually produce the proper upward velocity.)
@export_range(100, 1000, 10, "suffix:px") var defeated_y_velocity: float = 400.0

## The direction the enemy will start moving in.
@export_enum("Left:0", "Right:1") var start_direction: int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: int

var defeated := false

var on_screen := false

@onready var _sprite := %AnimatedSprite2D
@onready var _left_ray := %LeftRay
@onready var _right_ray := %RightRay
@onready var _body_collision: CollisionShape2D = %CollisionShape2D
@onready var _hitbox: Area2D = %Hitbox

var _reset_on_unpause: ResetOnUnpause
var _default_anim_name: StringName

func _set_speed(new_speed):
	speed = new_speed
	if is_node_ready():
		_sprite.speed_scale = speed / 100


func _ready():
	_default_anim_name = _sprite.animation
	_reset_on_unpause = ResetOnUnpause.new(self)
	_reset_on_unpause.on_reset.connect(_reset_after_defeat)

	Global.gravity_changed.connect(_on_gravity_changed)

	direction = -1 if start_direction == 0 else 1

func _reset_after_defeat() -> void:
	defeated = false
	velocity.x = 0
	velocity.y = 0
	_hitbox.monitorable = true
	_hitbox.monitoring = true
	_body_collision.disabled = false
	_sprite.flip_v = false
	_sprite.play(_default_anim_name)

func _physics_process(delta):
	if defeated:
		velocity.y += gravity * delta
		move_and_slide()
		if not on_screen:
			_reset_on_unpause.fake_free()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if not fall_off_edge and (_left_ray.is_colliding() or _right_ray.is_colliding()):
		if direction == -1 and not _left_ray.is_colliding():
			direction = 1
		elif direction == 1 and not _right_ray.is_colliding():
			direction = -1

	velocity.x = direction * speed

	_sprite.flip_h = velocity.x < 0

	move_and_slide()

	if velocity.x == 0 and is_on_floor():
		direction *= -1


func _on_gravity_changed(new_gravity):
	gravity = new_gravity


func _on_hitbox_body_entered(body):
	if body.is_in_group("players"):
		if squashable and body.velocity.y > 0 and body.position.y < position.y:
			body.stomp()
			defeat()
		elif player_loses_life:
			Global.lives += 1 # This is a hack to "get rid" of the lives/game over system without ripping everything out of the global game system.


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(5):
		player_loses_life = false
		queue_free()

func defeat(attack_sign: int = 0) -> void:
	_hitbox.monitorable = false
	_hitbox.monitoring = false
	_body_collision.disabled = true
	_sprite.stop()
	_sprite.flip_v = true
	if attack_sign != 0:
		velocity.x = abs(velocity.x) * attack_sign
	velocity.x *= defeated_x_velocity_multiplier
	velocity.y = -defeated_y_velocity
	defeated = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true
