extends GutTest

var shortcut: JustPressedButtonShortcut
var button: Button
var sender: GutInputSender = InputSender.new(Input)

func before_each():
	button = autofree(Button.new())
	shortcut = autofree(JustPressedButtonShortcut.new())
	shortcut.button = button
	shortcut.action = "player_action"

func after_each():
	sender.release_all()
	sender.clear()

func test_it_triggers_the_pressed_signal_when_action_just_pressed():
	var spy: CallableSpy = autofree(CallableSpy.new())
	button.pressed.connect(spy.callable)

	sender.action_up("player_action").wait_frames(1)
	shortcut._process(1)
	await(sender.idle)
	assert_eq(spy.get_number_of_calls(), 0)

	sender.action_down("player_action").wait_frames(1)
	shortcut._process(1)
	await(sender.idle)
	assert_eq(spy.get_number_of_calls(), 0)

	sender.action_up("player_action").wait_frames(1)
	shortcut._process(1)
	await(sender.idle)
	assert_eq(spy.get_number_of_calls(), 1)

func test_it_destroys_itself_if_button_is_null():
	shortcut.button = null
	add_child(shortcut)

	assert_true(shortcut.is_queued_for_deletion())