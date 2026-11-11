@tool
extends Node2D
class_name Switch
## An object that can trigger a signal when toggled on/off, and whose on/off state is persisted across transitions between edit and play modes.

## Whether the switch is currently on or not.
@export var on: bool = false:
	set(value):
		_on = value
		on_toggle.emit(_on)
	get:
		return _on

## The actual internal state of the switch
var _on: bool = false

signal hit(_attack_sign: int)
signal on_toggle(toggle: bool)

func _ready() -> void:
	hit.connect(func(_sign):
		on = not on
	)
	on_toggle.connect(func(enabled: bool):
		InGameQuestsBridge.set_node_property(self, "on", enabled)
	)
	on_toggle.emit(_on)

func _on_hittable_object_collision() -> void:
	hit.emit(0)
