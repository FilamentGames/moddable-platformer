extends GutTest

var gate: CollectibleGate

class MockBridgeBehavior extends AbstractBridgeBehavior:
	var gate_opened: bool = false

	func mark_gate_opened(_node: Node) -> void:
		gate_opened = true

	func deplete_collectible() -> void:
		pass

func before_each():
	gate = autofree(CollectibleGate.new())

func test_it_lights_up_the_first_lantern_by_default_if_required_scrolls_is_1():
	gate.lanterns = [
		autofree(CollectibleGateLantern.new()),
		autofree(CollectibleGateLantern.new()),
	]
	gate.required_collectibles = 1

	add_child(gate)

	assert_eq(gate.lanterns[0].lit, true)
	assert_eq(gate.lanterns[1].lit, false)

func test_it_sets_info_indicator_text_based_on_the_required_scrolls():
	gate.required_collectibles = 1
	gate.collectible_name = "Yarnspark"
	gate.info_indicator_label = autofree(RichTextLabel.new())

	add_child(gate)

	assert_string_contains(gate.info_indicator_label.text, "1 Yarnspark")
	assert_false(gate.info_indicator_label.text.contains("1 Yarnsparks"), "Should not be plural")

func test_it_sets_info_indicator_text_to_be_plural_if_required_scrolls_is_greater_than_1():
	gate.required_collectibles = 2
	gate.info_indicator_label = autofree(RichTextLabel.new())
	gate.collectible_name = "Yarnspark"

	add_child(gate)

	assert_string_contains(gate.info_indicator_label.text, "2 Yarnsparks")

func test_it_emits_an_event_when_the_player_enters_the_trigger_area_and_does_not_have_enough_scrolls():
	gate.required_collectibles = 10
	gate.bridge_behavior = autofree(MockBridgeBehavior.new())

	add_child(gate)

	gate.bridge_behavior.current_collectible_count = 1
	gate.bridge_behavior.is_ready = true

	var spy: CallableSpy = autofree(CallableSpy.new())
	gate.not_enough_collectibles.connect(spy.callable)

	gate.player_entered()

	assert_eq(spy._calls.size(), 1)

func test_it_emits_an_event_when_the_player_enters_the_trigger_area_and_has_enough_scrolls():
	gate.required_collectibles = 10
	gate.bridge_behavior = autofree(MockBridgeBehavior.new())

	add_child(gate)

	gate.bridge_behavior.current_collectible_count = 10
	gate.bridge_behavior.is_ready = true

	var spy: CallableSpy = autofree(CallableSpy.new())
	gate.gate_opening.connect(spy.callable)

	gate.player_entered()

	assert_eq(spy._calls.size(), 1)
	assert_true(gate.bridge_behavior.gate_opened, "Gate should be opened through bridge")

func test_it_emits_an_event_when_the_player_has_left_the_trigger_area():
	var spy: CallableSpy = autofree(CallableSpy.new())
	gate.hide_info_message.connect(spy.callable)

	gate.player_exited()

	assert_eq(spy._calls.size(), 1)

func test_it_retries_if_the_bridge_behavior_is_not_ready():
	gate.required_collectibles = 1
	gate.bridge_behavior = autofree(MockBridgeBehavior.new())
	gate.bridge_retry_timeout = 0.01

	var spy: CallableSpy = autofree(CallableSpy.new())
	gate.gate_opening.connect(spy.callable)

	add_child(gate)

	gate.bridge_behavior.is_ready = false
	gate.bridge_behavior.current_collectible_count = 0

	gate.player_entered()

	gate.bridge_behavior.current_collectible_count = 1
	gate.bridge_behavior.is_ready = true
	await wait_seconds(0.05)

	assert_eq(spy._calls.size(), 1)

func test_it_can_set_the_gate_opened() -> void:
	gate.to_delete_on_open = [
		autofree(Node2D.new()),
		autofree(Node2D.new()),
		autofree(Area2D.new()),
		autofree(Node.new()),
	]
	add_child(gate)

	gate.open()

	for node in gate.to_delete_on_open:
		assert_true(node.is_queued_for_deletion(), "Node should be queued for deletion")
