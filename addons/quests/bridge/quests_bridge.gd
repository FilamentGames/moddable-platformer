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
	var sender_id: int = _get_sender_id(data)
	var parsed_message = message.split(prefix + ":")[1]
	match parsed_message:
		"get_quest_text":
			_send_message(session_id, sender_id, "reply_get_quest_text", [GlobalQuests.quests.get_current_text()])
			return true
		"progress_quest":
			GlobalQuests.quests.next()
			_send_message(session_id, sender_id, "text_updated", [GlobalQuests.quests.get_current_text()])
			return true
	return false

func _setup_session(session_id):
	var session = get_session(session_id)
	session.started.connect(func (): print("Quest bridge started"))
	session.stopped.connect(func (): print("Quest bridge stopped"))
