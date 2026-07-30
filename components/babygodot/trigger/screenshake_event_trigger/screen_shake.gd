extends RefCounted
class_name ScreenShake

const TWEEN_META_KEY := &"_screen_shake_tween"
const OFFSET_META_KEY := &"_screen_shake_original_offset"

var _tween: Tween
var _camera: Camera2D
var _duration: float
var _strength: float
var _frequency: float

var _steps: int
var _step_duration: float

func _init(camera: Camera2D, duration: float, strength: float, frequency: float) -> void:
	_camera = camera
	_duration = duration
	_strength = strength
	_frequency = frequency

func run() -> void:
	if not is_instance_valid(_camera) or _duration <= 0.0 or _strength <= 0.0:
		return

	stop()

	if not _camera.has_meta(OFFSET_META_KEY):
		_camera.set_meta(OFFSET_META_KEY, _camera.offset)
	var original_offset: Vector2 = _camera.get_meta(OFFSET_META_KEY)

	_tween = _camera.create_tween()
	_camera.set_meta(TWEEN_META_KEY, _tween)

	_steps = maxi(1, int(_duration * _frequency))
	_step_duration = _duration / float(_steps)

	for i in _steps:
		_add_tween(i)

	_tween.tween_property(_camera, "offset", original_offset, _step_duration)
	_tween.finished.connect(func(): stop(), CONNECT_ONE_SHOT)

func _add_tween(i: int) -> void:
	var decay := 1.0 - float(i) / float(_steps)
	var shake_offset := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
	) * _strength * decay
	_tween.tween_property(_camera, "offset", shake_offset, _step_duration)


func stop() -> void:
	if _camera.has_meta(TWEEN_META_KEY):
		var existing: Tween = _camera.get_meta(TWEEN_META_KEY)
		if existing and existing.is_valid():
			existing.kill()
		_camera.remove_meta(TWEEN_META_KEY)

	if _camera.has_meta(OFFSET_META_KEY):
		_camera.offset = _camera.get_meta(OFFSET_META_KEY)
		_camera.remove_meta(OFFSET_META_KEY)
