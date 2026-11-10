extends BabyGodotTest

var switch: Switch

func before_all():
	InGameQuestsBridge._enabled = false

func before_each():
	switch = autofree(Switch.new())
	add_child(switch)

func test_it_can_be_switched():
	var spy := create_spy()
	switch.on_toggle.connect(spy.callable)

	switch.hit.emit(0)

	assert_eq(spy.get_number_of_calls(), 1)

func test_it_can_toggle_on_and_off():
	switch.on = false

	switch.hit.emit(0)

	assert_true(switch.on)
	
	switch.hit.emit(0)

	assert_false(switch.on)

func test_externally_setting_on_param_triggers_signal():
	switch.on = false
	var spy := create_spy()
	switch.on_toggle.connect(spy.callable)

	switch.on = true

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(spy._calls[0][0])
