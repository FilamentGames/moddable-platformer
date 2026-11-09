@tool
extends Control
class_name BabyGodotTitleScreen

var main_screen_reference

@export var continue_button: Button

func _enter_tree() -> void:
	continue_button.disabled = not GlobalQuests.quests._save_data_handler.has_save_file
	print(GlobalQuests.quests._save_data_handler.has_save_file)

func _on_new_game_button_pressed() -> void:
	if GlobalQuests.quests._save_data_handler.has_save_file:
		var dialog := ConfirmationDialog.new()
		dialog.title = "Erase Save Data?"
		dialog.dialog_text = "Starting a New Game will erase all your saved progress and return you to the beginning. Are you sure you want to do this?"

		dialog.confirmed.connect(_start_new_game)

		add_child(dialog)
		dialog.popup_centered()
		dialog.show()
	else:
		_start_new_game()

func _start_new_game() -> void:
	LevelResetter.instance.reset_levels()
	GlobalQuests.quests._save_data_handler.clear_data()
	GlobalQuests.quests.reset_progress()
	start()

func _on_continue_button_pressed() -> void:
	GlobalQuests.quests._save_data_handler.load_docks(GlobalQuests.quests)
	start()

func start() -> void:
	main_screen_reference.disable_title()
	GlobalQuests.quests.set_quest_dock_visible(true)
	EditorInterface.play_main_scene.call_deferred()
