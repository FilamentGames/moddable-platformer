extends GutTest

var dock: BabyGodotQuestDock

func before_each():
	dock = autofree(BabyGodotQuestDock.new())
	dock.text = autofree(Label.new())
	dock.next_button = autofree(Button.new())
	dock.quests_provider = autofree(BabyGodotQuests.new())
	dock.quests_provider.text_data = ["Lorem Ipsum", "Test"]
	add_child(dock)

func test_gets_quest_text_on_load():
	assert_eq(dock.text.text, "Lorem Ipsum")

func test_reacts_to_text_update():
	dock.quests_provider.next()
	assert_eq(dock.text.text, "Test")

func test_it_can_move_to_next_line_of_text():
	dock.next_button.pressed.emit()
	assert_eq(dock.text.text, "Test")

func test_it_disables_next_button_if_no_next():
	dock.next_button.pressed.emit()
	assert_true(dock.next_button.disabled, "Expected next button to be disabled")
