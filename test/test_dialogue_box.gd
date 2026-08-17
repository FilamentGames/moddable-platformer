extends GutTest

var dialogue: DialogueBox
var label: RichTextLabel
var next_button: Button

func before_each():
	dialogue = autofree(DialogueBox.new())
	label = autofree(RichTextLabel.new())
	next_button = autofree(Button.new())
	dialogue.label = label
	dialogue.next_button = next_button
	dialogue.adjust_position_if_cut_off = false

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

func test_it_emits_a_signal_and_queues_for_deletion_once_finished():
	var spy: CallableSpy = autofree(CallableSpy.new())
	dialogue.dialogue_lines = ["Lorem"]
	dialogue.finished.connect(spy.callable)
	add_child(dialogue)

	dialogue._on_next_button_click()

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(dialogue.is_queued_for_deletion())

func test_it_emits_a_signal_when_next_button_is_clicked():
	var spy: CallableSpy = autofree(CallableSpy.new())
	dialogue.dialogue_lines = ["Lorem", "Ipsum"]
	dialogue.next.connect(spy.callable)
	add_child(dialogue)

	dialogue._on_next_button_click()

	assert_eq(spy.get_number_of_calls(), 1)

func test_it_stops_animation_when_next_button_is_clicked_if_enabled():
	dialogue.next_button_stops_animation_first = true
	dialogue.dialogue_lines = ["Lorem", "Ipsum"]
	dialogue.label = autofree(AnimatedLabel.new())
	var animated_label: AnimatedLabel = dialogue.label as AnimatedLabel
	add_child(dialogue.label)
	add_child(dialogue)

	dialogue._on_next_button_click()

	assert_eq(animated_label.get_text(), "Lorem")

	dialogue._on_next_button_click()
	dialogue._on_next_button_click()

	assert_eq(animated_label.get_text(), "Ipsum")

func test_it_sets_the_canvas_layer_offset_to_the_global_position():
	dialogue.canvas_layer = autofree(CanvasLayer.new())
	dialogue.global_position = Vector2(100, 100)
	add_child(dialogue.canvas_layer)
	add_child(dialogue)

	assert_eq(dialogue.canvas_layer.offset, Vector2(100, 100))