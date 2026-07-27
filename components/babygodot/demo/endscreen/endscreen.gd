extends CanvasLayer
## Fades in when the demo is over

## How long this screen takes to fade in
@export_range(0.0, 10.0, 0.1, "s") var fade_in_duration := 3.0

@export_group("Internal Refs")

## The base control that will be faded in
@export var panel: Control

var _time: float

func _ready() -> void:
	_time = fade_in_duration

func _process(delta: float) -> void:
	_time -= delta
	panel.modulate.a = clamp(1.0 - _time / fade_in_duration, 0.0, 1.0)
