extends Node
class_name JustPressedButtonShortcut
## Adds "shortcut" functionality to a button but only on a `just_pressed` action input.

## The button to target
@export var button: Button

## The action to watch for
@export var action: StringName = &"player_action"

func _ready() -> void:
	if not button:
		queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(action):
		button.pressed.emit()