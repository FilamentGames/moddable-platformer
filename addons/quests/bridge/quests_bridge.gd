@tool
extends EditorDebuggerPlugin
class_name BabyGodotQuestsBridge
## An EditorDebuggerPlugin designed to act as a bridge between the editor's quest tools and stuff that happens in the game runtime.
## See: https://docs.godotengine.org/en/stable/classes/class_editordebuggerplugin.html

const prefix = "baby_godot"

## Contains a list of object IDs that have been collected, to remove at the end of the session to avoid making a lot of editor changes all at once.
var _collected_objects: Array[String] = []

## Contains the state of the editor's docks, so that they can be restored at the end of the session.
var _editor_unlock_state: Dictionary = {
	"inspector": false,
	"scene_tree": false,
}

func _has_capture(capture):
	return capture == prefix

func _send_message(session_id, object_id: int, message: String, data: Array) -> void:
	var full_data = [object_id]
	full_data.append_array(data)
	get_session(session_id).send_message(prefix + ":" + message, full_data)

func _get_sender_id(data: Array) -> int:
	if data.size() > 0:
		return data[0]
	return -1

func _capture(message, data, session_id):
	var sender_id := _get_sender_id(data)
	var parsed_message = message.split(prefix + ":")[1]
	match parsed_message:
		"get_quest_text":
			_send_message(session_id, sender_id, "reply_get_quest_text", [GlobalQuests.quests.get_current_text()])
			return true
		"get_all_nextbutton_quest_text":
			_send_message(session_id, sender_id, "reply_get_all_nextbutton_quest_text", [GlobalQuests.quests.get_all_nextbutton_quest_text()])
			return true
		"progress_quest":
			var trigger_type := QuestLine.ProgressMethod.ScriptTrigger
			if data.size() > 1:
				trigger_type = data[1]
			GlobalQuests.quests.next(trigger_type)
			_send_message(session_id, sender_id, "text_updated", [GlobalQuests.quests.get_current_text()])
			return true
		"save_player_position":
			GlobalQuests.quests.register_player_position(data[1])
			return true
		"collect_scroll":
			GlobalQuests.quests.collect_scroll(data[1])
			_send_message(session_id, -1, "scrolls_updated", [GlobalQuests.quests.scrolls_collected.size()])
			return true
		"get_number_of_scrolls":
			_send_message(session_id, sender_id, "reply_get_number_of_scrolls", [GlobalQuests.quests.scrolls_collected.size()])
			return true
		"set_inspector_dock_visible":
			_editor_unlock_state["inspector"] = data[1]
			return true
		"set_scene_tree_dock_visible":
			_editor_unlock_state["scene_tree"] = data[1]
			return true
		"register_mode_switch":
			GlobalQuests.quests.register_mode_switch(data[1])
			return true
		"set_current_edited_scene":
			GlobalQuests.quests.set_current_edited_scene(data[1])
			return true
		"activate_level_checkpoint":
			GlobalQuests.quests.activate_level_checkpoint(data[1])
			return true
		"delete_node_in_editor":
			GlobalQuests.quests.delete_node_in_editor(data[1])
			return true
		"update_editable_objects":
			GlobalQuests.quests.update_editable_objects(data[1], data[2])
			return true
		"collect_coin":
			GlobalQuests.quests.collect_coin()
			_collected_objects.append(data[1])
			return true
		"get_global_coins":
			_send_message(session_id, sender_id, "reply_get_global_coins", [GlobalQuests.quests.global_coins])
			return true
	return false

func _setup_session(session_id):
	var session = get_session(session_id)
	session.started.connect(_on_session_start)
	session.stopped.connect(_on_session_stop)
	GlobalQuests.quests.scroll_collected.connect(_on_scroll_collected.bind(session_id))

func _on_scroll_collected(session_id: int) -> void:
	_send_message(session_id, -1, "scrolls_updated", [GlobalQuests.quests.scrolls_collected.size()])

func _on_session_start() -> void:
	print("Quest bridge started")
	GlobalQuests.quests.set_inspector_dock_visible(_editor_unlock_state["inspector"])
	GlobalQuests.quests.set_scene_tree_dock_visible(_editor_unlock_state["scene_tree"])

func _on_session_stop() -> void:
	print("Quest bridge stopped")
	GlobalQuests.quests.delete_nodes_in_editor(_collected_objects, false)
	_collected_objects.clear()
	GlobalQuests.quests.update_player_position()
	GlobalQuests.quests.register_mode_switch(BabyGodotQuests.EditorMode.EDIT)
	GlobalQuests.quests.set_inspector_dock_visible(_editor_unlock_state["inspector"])
	GlobalQuests.quests.set_scene_tree_dock_visible(_editor_unlock_state["scene_tree"])