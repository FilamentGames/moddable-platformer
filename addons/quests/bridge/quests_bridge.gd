@tool
extends EditorDebuggerPlugin
class_name BabyGodotQuestsBridge
## An EditorDebuggerPlugin designed to act as a bridge between the editor's quest tools and stuff that happens in the game runtime.
## See: https://docs.godotengine.org/en/stable/classes/class_editordebuggerplugin.html

const prefix = "baby_godot"

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
			GlobalQuests.quests.set_inspector_dock_visible(data[1])
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
	return false

func _setup_session(session_id):
	var session = get_session(session_id)
	session.started.connect(func (): print("Quest bridge started"))
	session.stopped.connect(_on_session_stop)

func _on_session_stop() -> void:
	print("Quest bridge stopped")
	GlobalQuests.quests.update_player_position()
	GlobalQuests.quests.register_mode_switch(BabyGodotQuests.EditorMode.EDIT)