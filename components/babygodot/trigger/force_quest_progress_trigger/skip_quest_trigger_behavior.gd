extends AbstractTriggerBehavior
class_name SkipQuestTriggerBehavior

## The identifier of the quest line to skip to. Leave empty if you want to use the index instead.
@export var quest_line_identifier: String

## The index of the quest line to skip to. Set to -1 if unused.
@export var quest_line_index: int = -1

func run_trigger() -> void:
	if quest_line_identifier:
		InGameQuestsBridge.skip_to_text_line(quest_line_identifier)
	elif quest_line_index:
		InGameQuestsBridge.skip_to_text_line(quest_line_index)
