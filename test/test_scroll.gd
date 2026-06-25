@tool
extends GutTest

class MockScrollCondition extends ScrollCondition:
	var condition_met := false

	func get_label_text() -> String:
		return "Unit Testing Condition"
	
	func is_condition_met() -> bool:
		return condition_met

var scroll: Scroll
var condition: MockScrollCondition

func before_each():
	scroll = autofree(Scroll.new())
	scroll.label = autofree(RichTextLabel.new())
	condition = autofree(MockScrollCondition.new())
	scroll.add_child(condition)
	condition.owner = scroll

func test_it_shows_error_message_if_no_condition():
	scroll.remove_child(condition)
	add_child(scroll)

	assert_true(scroll.error_state)
	assert_string_contains(scroll.label.text, "ERROR")

func test_it_can_be_collected_when_condition_is_true():
	condition.condition_met = true
	add_child(scroll)

	scroll._player_collect()

	assert_false(scroll.error_state)
	assert_true(scroll.is_queued_for_deletion())

func test_it_cannot_be_collected_when_condition_is_false():
	condition.condition_met = false
	add_child(scroll)

	scroll._player_collect()

	assert_false(scroll.error_state)
	assert_false(scroll.is_queued_for_deletion())

func test_it_updates_its_error_state_when_condition_is_deleted():
	add_child(scroll)

	assert_false(scroll.error_state)

	scroll.remove_child(condition)

	assert_true(scroll.error_state)

func test_it_emits_a_signal_when_a_condition_status_changes():
	add_child(scroll)
	var spy: CallableSpy = autofree(CallableSpy.new())
	scroll.condition_updated.connect(spy.callable)

	condition.condition_met = true
	condition.condition_updated.emit(true)

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(spy._calls[0][0])

func test_it_emits_a_signal_when_it_is_collected_by_the_player():
	condition.condition_met = true
	add_child(scroll)
	var spy: CallableSpy = autofree(CallableSpy.new())
	scroll.collected.connect(spy.callable)

	scroll._player_collect()

	assert_eq(spy.get_number_of_calls(), 1)