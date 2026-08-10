extends Node2D

## How spread out the decorations are vertically. The higher the number, the higher above the camera the decorations may spawn.
@export var vertical_range: float = 350

## How much of the horizontal screen space is covered by these decorations. It is recommended that this area is greater than 1x the horizontal space so it looks more "natural".
@export_range(1.0, 2.0, 0.05, "x") var horizontal_scale: float = 1.1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_y: float
var velocity_y: float
var angular_velocity: float

func _ready() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport_rect().size / camera.zoom
		var center = camera.get_screen_center_position()
		var rect := Rect2(center - viewport_size / 2, viewport_size)
		global_position.x = randf_range(rect.position.x, rect.position.x + rect.size.x)
		var buffer_offset = rect.size.x / 2 * horizontal_scale
		global_position.x += randf_range(-buffer_offset, buffer_offset)
		global_position.y = randf_range(rect.position.y, rect.position.y - vertical_range)
		target_y = rect.position.y + rect.size.y + 100
		velocity_y = gravity
		rotation = randf_range(0, PI * 2)
		angular_velocity = randf_range(-0.1, 0.1)

func _physics_process(delta: float) -> void:
	velocity_y += gravity * delta
	global_position.y += velocity_y * delta
	rotation += angular_velocity
	if global_position.y >= target_y:
		queue_free()
