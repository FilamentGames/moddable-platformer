@tool
class_name Quest
extends Resource
## A quest resource that tracks quest information and progress

## The name/title of the quest
@export var quest_name: String = ""

## Description of the quest
@export_multiline var quest_description: String = ""

## List of quest steps/objectives
@export var steps: Array[String] = []

## Current step index (0-based)
@export var current_step: int = 0

## Progress value (0.0 to 1.0)
@export_range(0.0, 1.0) var progress: float = 0.0

## Character avatar texture/sprite frames resource path
@export var character_avatar_path: String = ""

## Get the current quest step text
func get_current_step() -> String:
	if steps.is_empty() or current_step < 0 or current_step >= steps.size():
		return ""
	return steps[current_step]

## Get the next quest step text (if available)
func get_next_step() -> String:
	if steps.is_empty() or current_step + 1 >= steps.size():
		return ""
	return steps[current_step + 1]

## Check if quest is complete
func is_complete() -> bool:
	return progress >= 1.0 or (not steps.is_empty() and current_step >= steps.size() - 1 and progress >= 1.0)
