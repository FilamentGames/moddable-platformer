@abstract
extends RefCounted
class_name SaveDataHandler
## Handles fetching and processing save data for the given platform.

var has_save_file := false

## Saves the current quest state into the proper location
func save(quests: BabyGodotQuests) -> void:
	var dict := {}
	dict["quests"] = {
		"player": BabyGodotUtils.serialize_vector2(quests._last_player_pos),
		"line": quests._current_text_line,
		"coins": quests.global_coins,
		"hint": quests._current_hint_index,
		"scrolls": quests.scrolls_collected,
		"docks": quests._unlocked_docks.values()
	}
	dict["checkpoint_quest"] = _serialize_checkpoint_data_progress(quests)
	dict["checkpoint"] = quests._checkpoint_helper.export()
	dict["session"] = quests._play_session_state if quests._play_session_state else {}
	_write_json(JSON.stringify(dict))
	has_save_file = true

func load(quests: BabyGodotQuests) -> void:
	var json := JSON.new()
	var err := json.parse(_fetch_data())
	if err != OK:
		# No save data exists or it's corrupted. Abort!
		return
	has_save_file = true
	var dict: Dictionary = json.data
	quests._last_player_pos = BabyGodotUtils.deserialize_vector2(dict["quests"]["player"])
	quests._current_text_line = dict["quests"]["line"]
	quests.global_coins = dict["quests"]["coins"]
	quests._current_hint_index = dict["quests"]["hint"]
	quests.scrolls_collected = dict["quests"]["scrolls"].duplicate()
	_deserialize_checkpoint_data_progress(quests, dict)
	quests._checkpoint_helper.import(dict["checkpoint"])
	quests._play_session_state = dict["session"] if dict.has("session") else {}
	quests.text_updated.emit()
	quests.coins_changed.emit()
	quests.scroll_collected.emit()

func _serialize_checkpoint_data_progress(quests: BabyGodotQuests) -> Dictionary:
	var dict := quests._checkpoint_quest_progress.duplicate()
	dict["last_position"] = [dict["last_position"].x, dict["last_position"].y]
	return dict

func _deserialize_checkpoint_data_progress(quests: BabyGodotQuests, dict: Dictionary) -> void:
	var d = dict["checkpoint_quest"]
	d["last_position"] = Vector2(d["last_position"][0], d["last_position"][1])
	quests._checkpoint_quest_progress = d

func load_docks(quests: BabyGodotQuests) -> void:
	var json := JSON.new()
	var err := json.parse(_fetch_data())
	if err != OK:
		# No save data exists or it's corrupted. Abort!
		return
	has_save_file = true
	var dict: Dictionary = json.data
	var unlocked_docks = dict["quests"]["docks"]
	var dock_method_map = {
		"quest": "set_quest_dock_visible",
		"scenetree": "set_scene_tree_dock_visible",
		"inspector": "set_inspector_dock_visible"
	}
	for method in dock_method_map.values():
		quests.call(method, false, false)
	for dock in unlocked_docks:
		quests.call(dock_method_map[dock], true)

@abstract func _write_json(data: String) -> void
@abstract func _fetch_data() -> String
@abstract func clear_data() -> void