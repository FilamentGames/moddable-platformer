extends Node2D
class_name DialogueBox
## A dialogue box for NPC dialogue, partially a simplified implementation of the Threadbare dialogue box.

## The lines of dialogue to show in this dialogue box
@export var dialogue_lines: Array[String]

@export_group("Internal Refs")
## The label which shows the current line of dialogue
@export var label: Label

## The button which progresses dialogue
@export var next_button: Button

## Emitted once dialogue is done and the dialogue box is queued for deletion
signal finished

func _ready() -> void:
	_get_next_text()

## Loads the next text or queues for deletion when there is no more text to fetch
func _get_next_text() -> void:
	if dialogue_lines.size() == 0:
		finished.emit()
		queue_free()
		return
	label.text = dialogue_lines.pop_front()

## Function wired up to be called when the next button is clicked
func _on_next_button_click():
	_get_next_text()
