@tool
extends Node
class_name AutoplayOnClone
## This is used to autoplay the game when the clone level is loaded. We previously tried using a pre-determined delay, but found that some machines were starting the game too early.

const auto_play_on_start_setting_name = "babygodot/auto_play_on_start"

var _autoplayed := false

func _is_clone_copy() -> bool:
	return EditorInterface.get_edited_scene_root().scene_file_path.begins_with("res://levels/clones/")

func _ready() -> void:
	if not Engine.is_editor_hint():
		InGameQuestsBridge.delete_node_in_editor(self)
		queue_free()
		return
	if not _is_clone_copy():
		return
	if ProjectSettings.get_setting(auto_play_on_start_setting_name) and not _autoplayed:
		EditorInterface.play_main_scene()
		_autoplayed = true
