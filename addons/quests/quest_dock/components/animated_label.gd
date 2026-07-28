@tool
extends Label
class_name AnimatedLabel
## A label that animates text in

## Amount of time between each character appearing in seconds
@export_range(0.005, 0.1, 0.005, "s") var seconds_per_character: float = 1.0/60.0

var _scroll_time: float = 0

func _ready():
	visible_characters = 0
	_scroll_time = 0

func _process(delta: float) -> void:
	if visible_characters < text.length():
		_scroll_time += delta
		visible_characters = floori(_scroll_time / seconds_per_character)

		# Skip spaces to scroll faster
		if text.length() < visible_characters and text[visible_characters] == " ":
			_scroll_time += seconds_per_character

func _set(property: StringName, value: Variant) -> bool:
	if property == &"text":
		visible_characters = 0
		_scroll_time = 0
	return false
