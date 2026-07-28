@tool
extends Control
class_name HintDisplay

## The text to display in the hint box
@export var hint: String

@export_group("Internal Refs")
## The label that displays the hint text
@export var label: Label

func _ready():
	_update_label_text()

func set_hint(text: String):
	hint = text
	_update_label_text()

func _update_label_text():
	if label:
		label.text = hint
