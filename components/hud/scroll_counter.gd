@tool
extends Control

## The label that shows the number of scrolls collected
@export var scroll_count_label: Label

var bridge: InGameQuestsBridge

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_scroll_label(GlobalQuests.quests.scrolls_collected.size())
		return
	bridge = InGameQuestsBridge.new()
	bridge.scroll_quantity.connect(_update_scroll_label)
	bridge.get_number_of_scrolls()

func _update_scroll_label(quantity: int) -> void:
	scroll_count_label.text = str(quantity)
