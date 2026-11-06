@abstract
extends RefCounted
class_name SaveDataHandler
## Handles fetching and processing save data for the given platform.

## Saves the current quest state into the proper location
func save(quests: BabyGodotQuests) -> void:
	var dict := {}
	dict["quests"] = {
		"line": quests._current_text_line,
		"coins": quests.global_coins,
		"hint": quests._current_hint_index,
		"scrolls": quests.scrolls_collected,
	}
	dict["checkpoint_quest"] = _serialize_checkpoint_data_progress(quests)
	dict["checkpoint"] = quests._checkpoint_helper.export()
	_write_json(JSON.stringify(dict))

func load(quests: BabyGodotQuests) -> void:
	var json := JSON.new()
	var err := json.parse(_fetch_data())
	if err != OK:
		# No save data exists or its corrupted. Abort!
		return
	var dict: Dictionary = json.data
	quests._current_text_line = dict["quests"]["line"]
	quests.global_coins = dict["quests"]["coins"]
	quests._current_hint_index = dict["quests"]["hint"]
	quests.scrolls_collected = dict["quests"]["scrolls"].duplicate()
	_deserialize_checkpoint_data_progress(quests, dict)
	quests._checkpoint_helper.import(dict["checkpoint"])
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

@abstract func _write_json(data: String) -> void
@abstract func _fetch_data() -> String
@abstract func clear_data() -> void