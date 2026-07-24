extends Node
class_name EditorGameMessagingService
## A class that maintains a single connection to the `BabyGodotQuestsBridge`, and essentially "multiplexes" that connection to specific objects in the game.

var _object_map: Dictionary[int, AbstractMessagingInbox] = {}

func _ready():
	if !get_tree().current_scene:
		## Disable the autoload singleton in tests
		queue_free()
		return
	_set_up_connection()

func _set_up_connection() -> void:
	EngineDebugger.register_message_capture("baby_godot", _capture)
	print("Connection established to EngineDebugger")

## Registers a game object with the messaging service
func connect_game_object(id: int, obj: AbstractMessagingInbox) -> void:
	_object_map[id] = obj

## Frees up a reference to a specific object ID in the object map
func free_id(id: int) -> void:
	_object_map.erase(id)

func _capture(message: String, data: Array) -> bool:
	var id = data.pop_front()
	# Handle "global" messages that could affect multiple objects at once
	if id == -1:
		return _handle_global_messages(message, data)
	# Handle messages directed to a specific object
	if _object_map.has(id):
		var recipient: AbstractMessagingInbox = _object_map[id]
		match message:
			"reply_get_quest_text":
				recipient.quest_text.emit(data[0])
				return true
			"reply_get_all_nextbutton_quest_text":
				recipient.all_nextbutton_quest_text.emit(data[0])
				return true
			"reply_get_number_of_scrolls":
				recipient.scroll_quantity.emit(data[0])
				return true
			"reply_get_global_coins":
				recipient.global_coins.emit(data[0])
				return true
	return false

func _handle_global_messages(message: String, data: Array) -> bool:
	match message:
		"text_updated":
			for obj: AbstractMessagingInbox in _object_map.values():
				obj.quest_text.emit(data[0])
			return true
		"scrolls_updated":
			for obj: AbstractMessagingInbox in _object_map.values():
				obj.scroll_quantity.emit(data[0])
	return false
