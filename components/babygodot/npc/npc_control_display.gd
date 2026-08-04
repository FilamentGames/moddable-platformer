extends Node2D
class_name ControlDisplay

## The node branch that includes the normal talk icon
@export var talk_display: Node2D

## The node branch that includes the controls
@export var control_display: Node2D

var _visible: bool = false

func show_control_display() -> void:
	_visible = true
	if talk_display and control_display:
		talk_display.hide()
		control_display.show()

func hide_control_display() -> void:
	_visible = false
	if talk_display and control_display:
		talk_display.show()
		control_display.hide()
