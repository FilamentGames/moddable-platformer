extends GutTest

var gate: Node
var gate_behavior: ScrollGateBehavior
var service: MockEditorGameMessagingService

func before_all():
	InGameQuestsBridge._enabled = false

func before_each():
	InGameQuestsBridge._clear_log()
	service = autofree(MockEditorGameMessagingService.new())
	gate = autofree(Node.new())
	gate.name = "Gate"
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

func test_it_marks_the_gate_for_deletion_and_depletes_scrolls():
	add_child(gate)

	gate_behavior.required_scrolls = 67
	gate_behavior.bridge.scroll_quantity.emit(100)

	assert_false(gate.is_queued_for_deletion())
	assert_not_null(gate.get_parent())

	gate_behavior.player_entered()

	assert_true(gate.is_queued_for_deletion())
	assert_null(gate.get_parent())

	assert_eq(InGameQuestsBridge._find_first_message_in_log("delete_node_in_editor")[1], [-1, "Gate"], "Gate should be marked for deletion")
	assert_eq(InGameQuestsBridge._find_first_message_in_log("deplete_scrolls")[1], [-1, 67], "Scrolls should be depleted")
