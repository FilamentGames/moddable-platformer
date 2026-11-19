extends PathFollow2D
class_name MovingPathNode
## An object that uses a PathFollow2D node to follow a Path2D, but with customizable parameters (speed, pause between loops, etc) [br]
## Use this as a parent to make objects like platforms move.

## The number of seconds for the object to move from the beginning of the path to the end of the path.
@export_range(0.1, 25.0, 0.1, "suffix:s") var cycle_time: float = 4.0

## The number of seconds the object pauses at its endpoints before continuing to move.
@export_range(0.1, 25.0, 0.1, "suffix:s") var pause_time: float = 4.0

var _t: float = 0.0

func _process(delta: float) -> void:
	_clamp_t_to_period()
	_t += delta
	progress_ratio = _triangle_wave()

func _clamp_t_to_period() -> void:
	_t = fmod(_t, (cycle_time + pause_time) * 2.0)

func _triangle_wave() -> float:
	var half_period := cycle_time + pause_time
	var t_period := _t / (half_period * 2.0)
	var pause_frac := pause_time / half_period
	var move_frac := cycle_time / half_period
	var triangle_wave := (2.0 * absf(t_period - floorf(t_period + 0.5)) - (1.0 - floorf(t_period + 0.5)) * pause_frac) / move_frac
	return clampf(triangle_wave, 0.0, 1.0)
