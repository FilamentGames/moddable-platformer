extends Resource
class_name QuestLine

enum ProgressMethod {
	NextButton, ## The player can press the next button to move to the next line of text.
	ModeSwitch, ## Switching between play/stop mode moves to the next line of text.
	SwitchToPlay, ## Only triggered when the player switches from edit mode to play mode
	SwitchToEdit, ## Only triggered when the player switches from play mode to edit mode
	ScriptTrigger, ## An in-game trigger object can move to the next line of text.
}

## The text to display in the dialogue box
@export var dialogue_line: String

## How to progress to the next line of of the quest
@export var progress_method: ProgressMethod = ProgressMethod.NextButton

## Should the elder do a little hip-hip-hooray animation when this quest line is reached?
@export var show_celebration_animation: bool = false

## Hints to display if the player buys a hint on this line of text.
@export var hints: Array[String] = []

## A unique identifier for this text line that can be used to skip to it. That way we don't have to use the index of the text line OR the text itself, which may be subject to change.
@export var identifier: String = ""