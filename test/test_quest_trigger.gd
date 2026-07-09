extends GutTest

class MockTriggerBehavior extends AbstractTriggerBehavior:
	var executed := false

	func run_trigger() -> void:
		executed = true

var trigger: QuestTrigger
var behavior: MockTriggerBehavior

func before_each():
	trigger = autofree(QuestTrigger.new())
	behavior = autofree(MockTriggerBehavior.new())
	trigger.behavior = behavior

func test_it_runs_the_trigger_behavior_when_player_detected():
	trigger._player_entered()

	assert_true(behavior.executed)
	assert_true(trigger.is_queued_for_deletion())

func test_it_does_not_error_if_no_behavior_is_specified():
	trigger.behavior = null
	trigger._player_entered()
	
	assert_false(behavior.executed)
	assert_true(trigger.is_queued_for_deletion())