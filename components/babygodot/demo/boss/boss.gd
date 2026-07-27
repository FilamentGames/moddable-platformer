@tool
extends Node2D
## Temporary boss behavior for proof-of-concept scope

## The radius of the circle the boss will fly around
@export_range(0.0, 500.0, 1.0, "px") var radius: float = 100.0:
	set(value):
		radius = value
		queue_redraw()

## How fast the boss completes a revolution
@export_range(0.0, 2.0, 0.1) var rotation_speed: float = 0.5

## Use this to show/hide the animated path display in the editor
@export var show_path_in_editor := true

@export_group("Internal Refs")
## The sprite which will rotate in a circle
@export var sprite: Node2D

var _t: float = 0

func _process(delta: float) -> void:
	_t += delta * rotation_speed
	if Engine.is_editor_hint():
		queue_redraw()
		return
	sprite.position.x = cos(_t) * radius
	sprite.position.y = sin(_t) * radius

func _draw() -> void:
	if Engine.is_editor_hint() and _is_master_level() and show_path_in_editor:
		draw_circle(Vector2.ZERO, radius, Color.BLACK, false, 1)
		var rotate_pos := Vector2(cos(_t) * radius, sin(_t) * radius)
		draw_circle(rotate_pos, 25, Color.RED, true)

func _is_master_level() -> bool:
	var master_level_lock = BabyGodotUtils.get_first_child_of_type(EditorInterface.get_edited_scene_root(), MasterLevelLock)
	return not not master_level_lock
