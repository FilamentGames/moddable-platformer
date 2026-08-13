extends GutTest

var behavior: ResetOnUnpause
var node: Node2D

func before_each():
	node = autofree(Node2D.new())
	behavior = autofree(ResetOnUnpause.new(node, autofree(MockEditorGameMessagingService.new())))
	behavior.hidden_position = Vector2(-1234, -1234)
	add_child(node)

func test_it_can_fake_destroy_a_node():
	behavior.fake_free()

	assert_false(node.visible)
	assert_true(behavior.inert)
	assert_false(node.can_process())
	assert_eq(node.position, behavior.hidden_position)

func test_it_can_reset_an_object_to_its_initial_position():
	node.position = Vector2(123, 456)
	behavior = autofree(ResetOnUnpause.new(node, autofree(MockEditorGameMessagingService.new())))

	behavior.fake_free()
	behavior.reset()

	assert_true(node.visible)
	assert_false(behavior.inert)
	assert_true(node.can_process())
	assert_eq(node.position, Vector2(123, 456))

func test_it_auto_listens_to_the_game_unpause_event():
	node.position = Vector2(123, 456)
	behavior = autofree(ResetOnUnpause.new(node, autofree(MockEditorGameMessagingService.new())))

	behavior.fake_free()
	behavior._bridge.game_unpaused.emit()

	assert_true(node.visible)
	assert_false(behavior.inert)
	assert_true(node.can_process())
	assert_eq(node.position, Vector2(123, 456))
	
func test_it_fires_a_signal_when_reset():
	var spy: CallableSpy = autofree(CallableSpy.new())
	behavior.on_reset.connect(spy.callable)

	behavior.reset()

	assert_eq(spy.get_number_of_calls(), 1)

func test_it_can_ignore_resetting_position():
	node.position = Vector2(123, 456)
	behavior = autofree(ResetOnUnpause.new(node, autofree(MockEditorGameMessagingService.new())))

	node.position = Vector2(456, 123)
	behavior.reset_position = false
	behavior.reset()

	assert_eq(node.position, Vector2(456, 123))