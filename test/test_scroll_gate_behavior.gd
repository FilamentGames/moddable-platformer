extends GutTest

var gate: Node
var gate_behavior: ScrollGateBehavior
var service: MockEditorGameMessagingService

func before_each():
	service = autofree(MockEditorGameMessagingService.new())
	gate = autofree(Node.new())
	gate_behavior = autofree(ScrollGateBehavior.new())
	gate_behavior.bridge = autofree(InGameQuestsBridge.new(service))
	gate_behavior.target_object = gate
	gate.add_child(gate_behavior)

func test_it_disappears_after_collecting_a_scroll():
	add_child(gate)

	gate_behavior.bridge.scroll_quantity.emit(1)

	assert_true(gate.is_queued_for_deletion())
	assert_null(gate.get_parent())

func test_it_does_nothing_if_scroll_quantity_not_reached():
	gate_behavior.required_scrolls = 100
	add_child(gate)

	gate_behavior.bridge.scroll_quantity.emit(1)

	assert_false(gate.is_queued_for_deletion())
	assert_not_null(gate.get_parent())
