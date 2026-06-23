extends GutTest

var dialogue: DialogueBox
var label: Label
var next_button: Button
var sender: GutInputSender = InputSender.new(Input)

func before_each():
	dialogue = autofree(DialogueBox.new())
	label = autofree(Label.new())
	next_button = autofree(Button.new())
	dialogue.label = label
	dialogue.next_button = next_button

func after_each():
	sender.release_all()
	sender.clear()

func test_it_does_nothing_if_no_dialogue():
	var spy: CallableSpy = autofree(CallableSpy.new())
	dialogue.finished.connect(spy.callable)
	add_child(dialogue)

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(dialogue.is_queued_for_deletion())

func test_it_loads_the_first_dialogue_into_the_label():
	dialogue.dialogue_lines = ["Test."]
	add_child(dialogue)

	assert_eq(label.text, "Test.")

func test_it_can_move_onto_next_dialogue_with_button():
	dialogue.dialogue_lines = ["Lorem", "Ipsum"]
	add_child(dialogue)
	dialogue._on_next_button_click()

	assert_eq(label.text, "Ipsum")

func test_it_can_move_onto_next_dialogue_with_input_action():
	dialogue.dialogue_lines = ["Lorem", "Ipsum"]
	add_child(dialogue)

	sender.action_down("player_action").wait_frames(1)
	dialogue._process(1)
	await(sender.idle)
	sender.action_up("player_action").wait_frames(1)
	dialogue._process(1)
	await(sender.idle)

	assert_eq(label.text, "Ipsum")

func test_it_emits_a_signal_and_queues_for_deletion_once_finished():
	var spy: CallableSpy = autofree(CallableSpy.new())
	dialogue.dialogue_lines = ["Lorem"]
	dialogue.finished.connect(spy.callable)
	add_child(dialogue)

	dialogue._on_next_button_click()

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(dialogue.is_queued_for_deletion())