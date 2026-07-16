extends AbstractMessagingInbox
class_name InGameQuestsBridge
## Object that communicates with the EditorGameMessagingService. Each instance acts as a unique "inbox" that the service can deliver messages to.

## The ID to be used for the next object
static var _next_id := 0

## Allows messaging to be disabled. This should always be true unless you're running in tests!
static var _enabled := true

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
	if _enabled:
		EngineDebugger.send_message("baby_godot:" + name, args)

## Requests the current quest text. Will be emitted from the `quest_text` signal once it is received.
func request_quest_text() -> void:
	_send_message("get_quest_text")

## Requests the next available lines of quest text that can be read with just the "Next Button" progress method
func request_all_nextbutton_quest_text() -> void:
	_send_message("get_all_nextbutton_quest_text")

## Registers a scroll with specific `scroll_id` as collected. Increases the scroll count and tells the continuity system to delete the scroll object in the editor.
func collect_scroll(scroll_id: String) -> void:
	_send_message("collect_scroll", [scroll_id])

## Requests the number of collected scrolls from the Quests system. Will be emitted from the `scroll_quantity` signal once it is received.
func get_number_of_scrolls() -> void:
	_send_message("get_number_of_scrolls")

## Move text forward in the current quest.
static func progress_quest(trigger_type: QuestLine.ProgressMethod = QuestLine.ProgressMethod.ScriptTrigger) -> void:
	_send_message_static("progress_quest", [-1, trigger_type])

## Save the player's last position in the continuity system
static func save_player_position(position: Vector2) -> void:
	_send_message_static("save_player_position", [-1, position])

## Set the Inspector Dock to be opened (`visible=true`) or hidden (`visible=false`)
static func set_inspector_dock_visible(visible: bool) -> void:
	_send_message_static("set_inspector_dock_visible", [-1, visible])

static func set_scene_tree_dock_visible(visible: bool) -> void:
	_send_message_static("set_scene_tree_dock_visible", [-1, visible])

## Signal to the quests system that the player has switched between play/edit mode
static func register_mode_switch(mode: BabyGodotQuests.EditorMode = BabyGodotQuests.EditorMode.PLAY) -> void:
	_send_message_static("register_mode_switch", [-1, mode])

static func set_current_edited_scene(path: String) -> void:
	_send_message_static("set_current_edited_scene", [-1, path])

static func activate_level_checkpoint(checkpoint_id: String) -> void:
	_send_message_static("activate_level_checkpoint", [-1, checkpoint_id])

static func delete_node_in_editor(node: Node) -> void:
	_send_message_static("delete_node_in_editor", [-1, UniqueSceneId.get_id(node)])