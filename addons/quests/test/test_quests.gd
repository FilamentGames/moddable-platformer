extends GutTest

var quests: BabyGodotQuests

func before_each():
	quests = autofree(BabyGodotQuests.new())
	quests.text_data = ["Lorem Ipsum", "Test"]

func test_has_quest_text():
	assert_eq(quests.get_current_text(), "Lorem Ipsum")

func test_can_move_to_next_text():
	quests.next()
	assert_eq(quests.get_current_text(), "Test")

func test_has_signal_when_text_updates():
	var spy = autofree(CallableSpy.new())
	quests.text_updated.connect(spy.callable)
	quests.next()
	assert_eq(spy.get_number_of_calls(), 1, "Expected `text_updated` signal to be called")

func test_stays_in_bounds_of_text_array():
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	quests.next()
	assert_eq(quests.get_current_text(), "Test")

func test_knows_when_text_is_done():
	quests.next()
	assert_false(quests.can_proceed(), "Expecting `can_proceed` to be false")
