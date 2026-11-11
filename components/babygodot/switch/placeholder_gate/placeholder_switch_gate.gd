@tool
extends Node2D

@export_range(25.0, 2000.0, 25.0, "suffix:ms") var open_speed: float = 1000.0

@export_group("Internal Refs")
@export var path_follow: PathFollow2D

var _enabled: bool = false

func on_toggle(enabled: bool) -> void:
	_enabled = enabled

func _process(delta: float) -> void:
	var progress = path_follow.progress_ratio
	var speed := delta * 1000.0 / open_speed
	if not _enabled:
		speed *= -1
	if Engine.is_editor_hint():
		speed = 0.1 * (-1 if not _enabled else 1)
	progress += speed
	path_follow.progress_ratio = clamp(progress, 0.0, 1.0)
