extends GutTest

var dock: BabyGodotQuestDock

func make_quest_line(text: String, progress_method := QuestLine.ProgressMethod.NextButton) -> QuestLine:
	var line: QuestLine = autofree(QuestLine.new())
	line.dialogue_line = text
	line.progress_method = progress_method
	return line

func before_each():
	dock = autofree(BabyGodotQuestDock.new())
	dock.text = autofree(Label.new())
	dock.next_button = autofree(Button.new())
	dock.hint_button = autofree(Button.new())
	dock.hint_display = autofree(HintDisplay.new())
	dock.quests_provider = autofree(BabyGodotQuests.new())
	dock.quests_provider.text_data = [make_quest_line("Lorem Ipsum"), make_quest_line("Test")]
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

func test_it_displays_hint_if_available():
	dock.quests_provider.text_data[0].hints = ["Test"]
	dock.quests_provider.global_coins = 10
	dock.quests_provider.hint_cost = 1
	dock.buy_hint()

	assert_eq(dock.hint_display.hint, "Test")
	assert_true(dock.hint_display.visible)

func test_it_does_not_display_hint_if_no_hint_is_available():
	dock.quests_provider.text_data[0].hints = []
	dock.quests_provider.global_coins = 10
	dock.quests_provider.hint_cost = 1
	dock.buy_hint()

	assert_false(dock.hint_display.visible)

func test_it_hides_the_hint_once_the_next_quest_line_is_loaded():
	dock.quests_provider.text_data[0].hints = ["Test"]
	dock.quests_provider.global_coins = 10
	dock.quests_provider.hint_cost = 1
	dock.buy_hint()

	dock.next()

	assert_false(dock.hint_display.visible)

func test_it_disables_hint_button_if_no_hint_is_available():
	dock.quests_provider.text_data[1].hints = []
	dock.next()

	assert_true(dock.hint_button.disabled)

func test_it_enables_hint_button_if_hint_is_available():
	dock.quests_provider.global_coins = 10
	dock.quests_provider.hint_cost = 1
	dock.quests_provider.text_data[1].hints = ["Test"]
	dock.next()

	assert_false(dock.hint_button.disabled)

func test_it_reacts_to_quest_provider_coin_changes():
	dock.quests_provider.global_coins = 0
	dock.quests_provider.hint_cost = 1
	dock.quests_provider.text_data[1].hints = ["Test"]
	dock.next()

	assert_true(dock.hint_button.disabled)

	dock.quests_provider.global_coins = 1
	dock.quests_provider.coins_changed.emit()

	assert_false(dock.hint_button.disabled)