extends GutTest

var gate: Node
var gate_behavior: ScrollGateBehavior
var service: MockEditorGameMessagingService

func before_all():
	InGameQuestsBridge._enabled = false

func before_each():
	service = autofree(MockEditorGameMessagingService.new())
	gate = autofree(Node.new())
	gate_behavior = autofree(ScrollGateBehavior.new())
	gate_behavior.bridge = autofree(InGameQuestsBridge.new(service))
	gate_behavior.target_object = gate
	gate.add_child(gate_behavior)

func test_it_disappears_after_collecting_a_scroll_and_the_player_enters_the_trigger_zone():
	add_child(gate)

	gate_behavior.bridge.scroll_quantity.emit(1)

	assert_false(gate.is_queued_for_deletion())
	assert_not_null(gate.get_parent())

	gate_behavior.player_entered()

	assert_true(gate.is_queued_for_deletion())
	assert_null(gate.get_parent())

func test_it_does_nothing_if_scroll_quantity_not_reached():
	gate_behavior.required_scrolls = 100
	add_child(gate)

	gate_behavior.bridge.scroll_quantity.emit(1)
	gate_behavior.player_entered()

	assert_false(gate.is_queued_for_deletion())
	assert_not_null(gate.get_parent())
