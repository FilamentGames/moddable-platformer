extends GutTest

var debugger_message_sent = false

class MockGameContinuityManager extends GameContinuityManager:
	var debugger_message_spy: CallableSpy

	func _on_delete() -> void:
		if debugger_message_spy:
			debugger_message_spy.callable.call()

var continuity: MockGameContinuityManager
var player: Node2D

func before_each():
	continuity = autofree(MockGameContinuityManager.new())
	player = autofree(Node2D.new())
	player.name = "Player"

func test_it_saves_the_players_current_position():
	continuity.register_player_object(player)
	player.position.x = 100
	player.position.y = -100
	continuity._process(1)

	var pos = continuity.get_player_objects_last_position()
	assert_eq(pos.x, 100.0)
	assert_eq(pos.y, -100.0)

func test_it_returns_an_error_value_if_no_player_registered():
	continuity._process(1)
	
	assert_eq(Vector2.INF, continuity.get_player_objects_last_position())

func test_it_doesnt_return_an_error_value_if_the_player_was_registered_and_then_deleted():
	continuity.register_player_object(player)
	player.position.x = 100
	player.position.y = -100
	continuity._process(1)
	player.free()
	
	assert_ne(Vector2.INF, continuity.get_player_objects_last_position())

func test_it_sends_a_debugger_message_on_delete():
	continuity.register_player_object(player)
	player.position.x = 100
	player.position.y = -100
	continuity._process(1)
	var spy: CallableSpy = autofree(CallableSpy.new())
	continuity.debugger_message_spy = spy

	continuity.free()

	assert_eq(spy.get_number_of_calls(), 1)