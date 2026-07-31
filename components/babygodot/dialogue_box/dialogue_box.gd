extends Node2D
class_name DialogueBox
## A dialogue box for NPC dialogue, partially a simplified implementation of the Threadbare dialogue box.

## The lines of dialogue to show in this dialogue box
@export var dialogue_lines: Array[String]

## If the animated text should stop animating when the next button is clicked.
@export var next_button_stops_animation_first: bool = true

@export_group("Internal Refs")
## The label which shows the current line of dialogue
@export var label: Label

## The button which progresses dialogue
@export var next_button: Button

## The canvas layer the dialogue box is in
@export var canvas_layer: CanvasLayer

## Emitted once dialogue is done and the dialogue box is queued for deletion
signal finished

## Emitted when the next button is pressed
signal next

func _ready() -> void:
	if canvas_layer:
		canvas_layer.offset = global_position
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
	if next_button_stops_animation_first and label is AnimatedLabel:
		var animated_label: AnimatedLabel = label as AnimatedLabel
		if animated_label.is_animating():
			animated_label.show_all()
			return
	next.emit()
	_get_next_text()
