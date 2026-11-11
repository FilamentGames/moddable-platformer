extends Node2D
class_name TimedSwitch

## The number of seconds this switch is active before it toggles off.
@export var seconds_active: float = 5.0

@onready var _switch = %Switch
@onready var _timer = %Timer

signal on_toggle(enabled: bool)

func _ready() -> void:
	_switch.on_toggle.connect(_set_timer)
	_timer.timeout.connect(func():
		_switch.on = false
	)

func _set_timer(enabled: bool) -> void:
	if enabled:
		_timer.wait_time = seconds_active
		_timer.start()
	else:
		_timer.stop()
	on_toggle.emit(enabled)
