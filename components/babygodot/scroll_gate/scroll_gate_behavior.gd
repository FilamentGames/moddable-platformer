@tool
extends Node
class_name ScrollGateBehavior
## Deletes the target object if the collected number of scrolls is greater than or equal to the target amount.

## The number of collectibles required to open the gate.
@export var required_scrolls: int = 1

## The object to delete when the gate is opened.
@export var target_object: Node

## Emitted when the player enters the trigger zone and doesn't have enough collectibles.
signal show_info_message()

## Emitted when the player exits the trigger zone.
signal hide_info_message()

## Emitted when the target object is deleted.
signal target_object_deleted()

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
	print_stack()
	if _scroll_quantity >= required_scrolls:
		InGameQuestsBridge.delete_node_in_editor(target_object)
		InGameQuestsBridge.deplete_scrolls(required_scrolls)
		target_object.get_parent().remove_child(target_object)
		target_object.queue_free()
		queue_free.call_deferred()
		target_object_deleted.emit()
	else:
		show_info_message.emit()

func player_exited() -> void:
	hide_info_message.emit()
