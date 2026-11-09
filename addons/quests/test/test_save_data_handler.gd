extends BabyGodotTest

class MockSaveDataHandler extends SaveDataHandler:
	static var saved_data: String

	func _write_json(data: String) -> void:
		MockSaveDataHandler.saved_data = data

	func _fetch_data() -> String:
		return MockSaveDataHandler.saved_data

	func clear_data() -> void:
		MockSaveDataHandler.saved_data = ""

class StubEditorSceneProvider extends RefCounted:
	var docks := {
		"quest": false,
		"inspector": false,
		"scenetree": false
	}

	func save_editor_scene_as_checkpoint():
		pass
	
	func set_inspector_dock_visible(visible: bool):
		docks["inspector"] = visible
	
	func set_scene_tree_dock_visible(visible: bool):
		docks["scenetree"] = visible
	
	func set_quest_dock_visible(visible: bool):
		docks["quest"] = visible

var handler: MockSaveDataHandler
var quests: BabyGodotQuests
var editor_interface: FakeEditorInterface
var docks: StubEditorSceneProvider

func populate_quests_data() -> void:
	quests.text_data = []
	for i in 100:
		var quest_line = QuestLine.new()
		quest_line.dialogue_line = "Hi"
		quests.text_data.push_back(quest_line)

func before_each():
	handler = autofree(MockSaveDataHandler.new())
	handler.clear_data()
	quests = autofree(BabyGodotQuests.new())
	populate_quests_data()
	docks = StubEditorSceneProvider.new()
	quests.editor_scene_provider = docks
	editor_interface = FakeEditorInterface.new()
	editor_interface.scene_root = autofree(Node.new())
	quests._checkpoint_helper = autofree(CheckpointHelper.new(editor_interface))
	quests._checkpoint_helper.undo_redo = FakeUndoRedo.new()
	quests._checkpoint_helper.save_editor_scene_as_checkpoint()

func test_it_can_save_quest_data():
	quests._current_text_line = 13
	quests.global_coins = 67
	quests._current_hint_index = 1
	quests.scrolls_collected = ["Yarnspark", "Yarnspark2"]
	handler.save(quests)

	var dict := JSON.parse_string(MockSaveDataHandler.saved_data)

	assert_true(dict.has("quests"))
	assert_eq(dict["quests"]["line"], 13.0)
	assert_eq(dict["quests"]["coins"], 67.0)
	assert_eq(dict["quests"]["hint"], 1.0)
	assert_eq(dict["quests"]["scrolls"], ["Yarnspark", "Yarnspark2"])

func test_it_can_load_quest_data():
	quests._current_text_line = 13
	quests.global_coins = 67
	quests._current_hint_index = 1
	quests.scrolls_collected = ["Yarnspark", "Yarnspark2"]
	handler.save(quests)

	quests.free()
	quests = autofree(BabyGodotQuests.new())
	quests.editor_scene_provider = docks
	quests._checkpoint_helper = autofree(CheckpointHelper.new(editor_interface))
	quests._checkpoint_helper.undo_redo = FakeUndoRedo.new()
	populate_quests_data()
	handler.load(quests)

	assert_eq(quests._current_text_line, 13)
	assert_eq(quests.global_coins, 67)
	assert_eq(quests._current_hint_index, 1)
	assert_eq(quests.scrolls_collected, ["Yarnspark", "Yarnspark2"])

func test_it_can_also_save_checkpoint_data():
	var node: Node2D = autofree(Node2D.new())
	node.name = "Potato"
	editor_interface.scene_root.add_child(node)
	quests._checkpoint_helper.register_node_added(node)
	quests._current_text_line = 13
	quests.global_coins = 67
	quests._current_hint_index = 1
	quests.scrolls_collected = ["Yarnspark", "Yarnspark2"]
	quests._checkpoint_quest_progress["last_position"] = Vector2(13, 37)
	quests.save_checkpoint()
	handler.save(quests)

	var dict := JSON.parse_string(MockSaveDataHandler.saved_data)

	assert_true(dict.has("checkpoint_quest"))
	assert_true(dict.has("checkpoint"))

	assert_eq(dict["checkpoint_quest"]["text_line"], 13.0)
	assert_eq(dict["checkpoint_quest"]["global_coins"], 67.0)
	assert_eq(dict["checkpoint_quest"]["scrolls_collected"], ["Yarnspark", "Yarnspark2"])
	assert_eq(dict["checkpoint_quest"]["last_position"], [13.0, 37.0])

	assert_array_contains(dict["checkpoint"]["added"], "Potato")

func test_it_can_also_load_checkpoint_data():
	var node: Node2D = autofree(Node2D.new())
	node.name = "Potato"
	editor_interface.scene_root.add_child(node)
	quests._checkpoint_helper.register_node_added(node)
	quests._current_text_line = 13
	quests.global_coins = 67
	quests._current_hint_index = 1
	quests.scrolls_collected = ["Yarnspark", "Yarnspark2"]
	quests._checkpoint_quest_progress["last_position"] = Vector2(13, 37)
	quests.save_checkpoint()
	handler.save(quests)

	quests.free()
	quests = autofree(BabyGodotQuests.new())
	quests.editor_scene_provider = docks
	quests._checkpoint_helper = autofree(CheckpointHelper.new(editor_interface))
	quests._checkpoint_helper.undo_redo = FakeUndoRedo.new()
	populate_quests_data()
	handler.load(quests)

	assert_array_contains(quests._checkpoint_helper.scene_delta._added_nodes, "Potato")

func test_it_does_nothing_if_no_save_data_found_when_loading():
	handler.load(quests)

	assert_eq(quests._current_text_line, 0)

func test_it_saves_and_loads_dock_state():
	quests.set_quest_dock_visible(true)
	quests.set_scene_tree_dock_visible(true)
	quests.set_inspector_dock_visible(false)

	handler.save(quests)

	var dict := JSON.parse_string(MockSaveDataHandler.saved_data)

	assert_true(dict["quests"].has("docks"))
	assert_array_contains(dict["quests"]["docks"], "quest")
	assert_array_contains(dict["quests"]["docks"], "scenetree")
	assert_array_does_not_contain(dict["quests"]["docks"], "inspector")

	docks.docks["quest"] = false
	docks.docks["scenetree"] = false
	docks.docks["inspector"] = true

	handler.load_docks(quests)

	assert_true(docks.docks["quest"])
	assert_true(docks.docks["scenetree"])
	assert_false(docks.docks["inspector"])