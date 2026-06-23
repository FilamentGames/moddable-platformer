extends AbstractMessagingInbox
class_name InGameQuestsBridge
## Object that communicates with the EditorGameMessagingService. Each instance acts as a unique "inbox" that the service can deliver messages to.

## The ID to be used for the next object
static var _next_id := 0

## A link to the current EditorGameMessagingService
var _service: EditorGameMessagingService

func _init(service: EditorGameMessagingService = GlobalMessagingService):
	id = _next_id
	_next_id += 1
	service.connect_game_object(id, self)
	_service = service

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# In tests, the service might be autofreed before the other game objects, so check if the service instance is still valid.
		if is_instance_valid(_service):
			_service.free_id(id)
			# Tell the messaging service that this object has been deleted and free up the reference to it in the object map
		
func _send_message(name: String, args: Array = []) -> void:
	var all_args: Array = [id]
	all_args.append_array(args)
	_send_message_static(name, all_args)

static func _send_message_static(name: String, args: Array = []) -> void:
	EngineDebugger.send_message("baby_godot:" + name, args)

## Requests the current quest text. Will be emitted from the `quest_text` signal once it is received.
func request_quest_text() -> void:
	_send_message("get_quest_text")

## Move text forward in the current quest.
static func progress_quest() -> void:
	_send_message_static("progress_quest")

static func save_player_position(position: Vector2) -> void:
	_send_message_static("save_player_position", [-1, position])