@tool
extends Node
class_name BabyGodotQuests
## The singleton object for the global "Quests" system, will store current quest progress

## The list of text lines for the quest. This will probably be replaced with a more robust system that is handled by a resource in the future.
@export var text_data: Array[String] = []

## Dispatched when text in the quest window is updated
signal text_updated()

var _current_text_line: int = 0

## Get the current line of text of the quest
func get_current_text() -> String:
	return text_data[_current_text_line]

## Move to the next line of text
func next() -> void:
	_current_text_line += 1
	_current_text_line = min(_current_text_line, text_data.size() - 1)
	text_updated.emit()

## If the UI can manually proceed to the next line of text
func can_proceed() -> bool:
	return _current_text_line < text_data.size() - 1
