extends GutTest

var quests: BabyGodotQuests

func make_quest_line(text: String, progress_method := QuestLine.ProgressMethod.NextButton) -> QuestLine:
	var line: QuestLine = autofree(QuestLine.new())
	line.dialogue_line = text
	line.progress_method = progress_method
	return line

func before_each():
	quests = autofree(BabyGodotQuests.new())
	quests.text_data = [make_quest_line("Lorem Ipsum"), make_quest_line("Test")]

func test_has_quest_text():
	assert_eq(quests.get_current_text(), "Lorem Ipsum")

func test_can_move_to_next_text():
	quests.next()
	assert_eq(quests.get_current_text(), "Test")

func test_has_signal_when_text_updates():
	var spy = autofree(CallableSpy.new())
	quests.text_updated.connect(spy.callable)
	quests.next()
	assert_eq(spy.get_number_of_calls(), 1, "Expected `text_updated` signal to be called")

func test_stays_in_bounds_of_text_array():
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	assert_eq(quests.get_current_text(), "Test")

func test_knows_when_text_is_done():
	quests.next()
	assert_false(quests.can_proceed(), "Expecting `can_proceed` to be false")

func test_cannot_manually_proceed_if_progressmethod_is_not_nextbutton():
	quests.text_data = [make_quest_line("Lorem Ipsum", QuestLine.ProgressMethod.ScriptTrigger), make_quest_line("Test")]

	assert_false(quests.can_proceed())

	quests.next()
	assert_eq(quests.get_current_text(), "Lorem Ipsum")

	quests.next(QuestLine.ProgressMethod.ScriptTrigger)
	assert_eq(quests.get_current_text(), "Test")

func test_can_register_a_mode_switch():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum", QuestLine.ProgressMethod.ModeSwitch), make_quest_line("Test")]

	for i in 5:
		quests.register_mode_switch()
	
	assert_eq(quests.get_current_text(), "Lorem")

	quests.next()
	quests.register_mode_switch()

	assert_eq(quests.get_current_text(), "Test")

func test_can_register_a_switch_to_play_mode():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum", QuestLine.ProgressMethod.SwitchToPlay), make_quest_line("Test")]

	for i in 5:
		quests.register_mode_switch(BabyGodotQuests.EditorMode.PLAY)
	
	assert_eq(quests.get_current_text(), "Lorem")

	quests.next()
	quests.register_mode_switch(BabyGodotQuests.EditorMode.EDIT)

	assert_eq(quests.get_current_text(), "Ipsum")

	quests.register_mode_switch(BabyGodotQuests.EditorMode.PLAY)

	assert_eq(quests.get_current_text(), "Test")

func test_can_get_next_lines_progressable_with_just_next_button():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum", QuestLine.ProgressMethod.ScriptTrigger), make_quest_line("Test")]

	assert_eq(quests.get_all_nextbutton_quest_text(), ["Lorem", "Ipsum"])

	quests.next()
	quests.next(QuestLine.ProgressMethod.ScriptTrigger)

	assert_eq(quests.get_all_nextbutton_quest_text(), ["Test"])

class MockSceneProvider:
	var _scene: Node2D
	var _player: Player

	var _camera_pos: Vector2
	var _zoom: float

	func get_editor_scene() -> Node2D:
		var scene = Node2D.new()
		var player = Player.new()
		player.name = "Potato"
		scene.add_child(player)
		player.owner = scene
		_scene = scene
		_player = player
		return scene
	
	func update_and_save_node(node: Node) -> void:
		pass
	
	func set_2d_viewport_focus(position: Vector2, zoom: float) -> void:
		_camera_pos = position
		_zoom = zoom

func test_it_can_update_the_players_position_in_editor():
	quests.default_editor_zoom = randfn(0.0, 1.0)
	var provider = autofree(MockSceneProvider.new())
	quests.editor_scene_provider = provider
	quests.register_player_position(Vector2(25, 50))
	quests.update_player_position()

	assert_eq(provider._player.position.x, 25.0)
	assert_eq(provider._player.position.y, 50.0)

	assert_eq(provider._camera_pos, provider._player.position, "Camera is focused on player position")
	assert_eq(provider._zoom, quests.default_editor_zoom, "Zoom level is configurable on quest object")

	provider._player.free()
	provider._scene.free()

class MockScrollSceneProvider extends MockSceneProvider:
	var _scroll: Scroll

	func get_editor_scene() -> Node2D:
		var scene = Node2D.new()
		scene.scene_file_path = "res://testing_file.tscn"
		var scroll = Scroll.new()
		scroll.name = "UnitTestScroll"
		scene.add_child(scroll)
		scroll.owner = scene
		_scene = scene
		_scroll = scroll
		return scene

func test_it_can_register_a_scroll_as_collected():
	var spy: CallableSpy = autofree(CallableSpy.new())
	quests.scroll_collected.connect(spy.callable)
	var provider = autofree(MockScrollSceneProvider.new())
	quests.editor_scene_provider = provider

	quests.collect_scroll("res://testing_file.tscn%UnitTestScroll")

	assert_not_null(provider._scroll, "The scroll is now deleted as part of the quests bridge being cleared")
	assert_not_null(provider._scene)
	assert_eq(quests.scrolls_collected.size(), 1)
	assert_eq(spy.get_number_of_calls(), 1)

	provider._scene.free()

func test_can_check_if_a_hint_is_available_for_the_current_text():
	quests.text_data = [make_quest_line("Lorem")]
	quests.text_data[0].hints = []

	assert_false(quests.can_buy_hint())

	quests.text_data[0].hints = ["Test"]
	quests.global_coins = 0

	assert_false(quests.can_buy_hint())

	quests.hint_cost = 5
	quests.global_coins = 10

	assert_true(quests.can_buy_hint())

func test_can_buy_a_hint():
	quests.text_data = [make_quest_line("Lorem")]
	quests.text_data[0].hints = ["Test"]
	quests.global_coins = 10
	quests.hint_cost = 5

	var text = quests.buy_hint()

	assert_eq(quests.global_coins, 5)
	assert_eq(quests.text_data[0].hints.size(), 1)
	assert_eq(text, "Test")

func test_it_resets_the_current_hint_index_when_moving_to_the_next_text_line():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum")]
	quests.text_data[0].hints = ["Test"]
	quests.text_data[1].hints = ["Test2", "Test3"]
	quests.global_coins = 10
	quests.hint_cost = 5

	quests.buy_hint()
	quests.next()
	var text = quests.buy_hint()

	assert_eq(text, "Test2")


func test_does_not_buy_a_hint_if_the_player_does_not_have_enough_coins():
	quests.text_data = [make_quest_line("Lorem")]
	quests.text_data[0].hints = ["Test"]
	quests.global_coins = 4
	quests.hint_cost = 5

	var text = quests.buy_hint()

	assert_eq(quests.global_coins, 4)
	assert_eq(quests.text_data[0].hints.size(), 1)
	assert_null(text)

func test_does_not_buy_a_hint_if_there_is_no_hint_available():
	quests.text_data = [make_quest_line("Lorem")]
	quests.text_data[0].hints = []
	quests.global_coins = 1000
	quests.hint_cost = 5

	var text = quests.buy_hint()

	assert_eq(quests.global_coins, 1000)
	assert_null(text)

func test_it_skips_to_the_next_script_trigger_text_line_with_a_script_trigger_progress_method():
	quests.text_data = [
		make_quest_line("Lorem", QuestLine.ProgressMethod.NextButton),
		make_quest_line("Ipsum", QuestLine.ProgressMethod.NextButton),
		make_quest_line("Test", QuestLine.ProgressMethod.ScriptTrigger),
		make_quest_line("Test2", QuestLine.ProgressMethod.ScriptTrigger),
	]

	quests.next(QuestLine.ProgressMethod.ScriptTrigger)

	assert_eq(quests.get_current_text(), "Test2")

func test_it_can_skip_to_a_specific_text_line():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum"), make_quest_line("Test")]
	quests.text_data[0].identifier = "lorem"
	quests.text_data[1].identifier = "ipsum"
	quests.text_data[2].identifier = "test"

	quests.skip_to_text_line(2)

	assert_eq(quests.get_current_text(), "Test")

	quests.skip_to_text_line("ipsum")

	assert_eq(quests.get_current_text(), "Ipsum")

func test_it_does_nothing_if_skipping_to_a_text_line_that_does_not_exist():
	quests.text_data = [make_quest_line("Lorem"), make_quest_line("Ipsum"), make_quest_line("Test")]

	quests.skip_to_text_line(10)

	assert_eq(quests.get_current_text(), "Lorem")

	quests.skip_to_text_line("not_a_valid_identifier")

	assert_eq(quests.get_current_text(), "Lorem")