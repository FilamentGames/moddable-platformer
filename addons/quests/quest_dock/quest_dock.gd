@tool
extends Control
class_name BabyGodotQuestDock

## The Label control that displays the current quest text
@export var text: Label

## The Button control that moves to the next step. This might end up being a debug-only control?
@export var next_button: Button

## The instance of BabyGodotQuests object we're getting data from.
var quests_provider: BabyGodotQuests

func _enter_tree() -> void:
	if !quests_provider:
		quests_provider = GlobalQuests.quests
	if !text || !quests_provider:
		return
	update_text()
	quests_provider.text_updated.connect(update_text)
	next_button.pressed.connect(next)

func update_text():
	text.text = quests_provider.get_current_text()

func next():
	quests_provider.next()
	next_button.disabled = !quests_provider.can_proceed()
