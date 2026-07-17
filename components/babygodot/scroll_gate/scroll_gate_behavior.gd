@tool
extends Node
class_name ScrollGateBehavior
## Deletes the target object if the collected number of scrolls is greater than or equal to the target amount.

@export var required_scrolls: int = 1

@export var target_object: Node

var bridge: InGameQuestsBridge

var _scroll_quantity: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		# Access the global var directly in editor
		_on_scroll_collected(GlobalQuests.quests.scrolls_collected.size())
		return
	if not bridge:
		bridge = InGameQuestsBridge.new()
	bridge.scroll_quantity.connect(_on_scroll_collected)
	bridge.get_number_of_scrolls()
	

func _on_scroll_collected(quantity: int) -> void:
	_scroll_quantity = quantity

func player_entered() -> void:
	if _scroll_quantity >= required_scrolls:
		target_object.get_parent().remove_child(target_object)
		target_object.queue_free()
		queue_free()
