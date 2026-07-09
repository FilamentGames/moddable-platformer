extends AbstractTriggerBehavior

@export var trigger_type: QuestLine.ProgressMethod = QuestLine.ProgressMethod.ScriptTrigger

func run_trigger() -> void:
	InGameQuestsBridge.progress_quest(trigger_type)