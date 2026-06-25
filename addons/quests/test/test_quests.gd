extends GutTest

var quests: BabyGodotQuests

func before_each():
	quests = autofree(BabyGodotQuests.new())
	quests.text_data = ["Lorem Ipsum", "Test"]

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

class MockSceneProvider:
	var _scene: Node2D
	var _player: Player

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

func test_it_can_update_the_players_position_in_editor():
	var provider = autofree(MockSceneProvider.new())
	quests.editor_scene_provider = provider
	quests.update_player_position(Vector2(25, 50))

	assert_eq(provider._player.position.x, 25.0)
	assert_eq(provider._player.position.y, 50.0)

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

	assert_null(provider._scroll)
	assert_not_null(provider._scene)
	assert_eq(quests.scrolls_collected.size(), 1)
	assert_eq(spy.get_number_of_calls(), 1)

	provider._scene.free()