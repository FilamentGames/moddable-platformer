extends Resource
class_name QuestLine

enum ProgressMethod {
	NextButton, ## The player can press the next button to move to the next line of text.
	ModeSwitch, ## Switching between play/stop mode moves to the next line of text.
	ScriptTrigger, ## An in-game trigger object can move to the next line of text.
}

@export var dialogue_line: String

@export var progress_method: ProgressMethod = ProgressMethod.NextButton
