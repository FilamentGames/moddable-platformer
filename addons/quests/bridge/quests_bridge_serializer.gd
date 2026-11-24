extends RefCounted
class_name QuestsBridgeSerializer
## Used for exporting/importing active BabyGodotQuestsBridge state to the save/load system.

static func serialize(bridge: BabyGodotQuestsBridge) -> Dictionary:
	return {
		"collected": bridge._collected_objects,
		"swapped": bridge._swapped_objects,
		"set": bridge._set_properties,
		"unlocks": bridge._editor_unlock_state
	}

static func hydrate(dict: Dictionary, quests: BabyGodotQuests = GlobalQuests.quests) -> void:
	quests.delete_nodes_in_editor(dict["collected"])
	quests.swap_nodes_with_prefabs(_restore_dictionary_type(dict["swapped"]))
	quests.set_node_properties(_restore_dictionary_type(dict["set"]))
	## TODO: unlocks?

static func _restore_dictionary_type(arr: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in arr:
		if i is Dictionary:
			out.push_back(i)
	return out
