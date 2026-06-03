@tool
extends Node
class_name GlobalQuests
## Static class that holds global Quest data

## The instance to the quests object
static var quests: BabyGodotQuests

static func get_quest_text_index() -> int:
	return quests._current_text_line
