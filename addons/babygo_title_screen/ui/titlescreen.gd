@tool
extends Control
class_name BabyGodotTitleScreen

var main_screen_reference

func _on_new_game_button_pressed() -> void:
	LevelResetter.instance.reset_levels()
	GlobalQuests.quests._save_data_handler.clear_data()
	GlobalQuests.quests.reset_progress()
	start()

func _on_continue_button_pressed() -> void:
	start()

func start() -> void:
	main_screen_reference.disable_title()
	GlobalQuests.quests.set_quest_dock_visible(true)
	EditorInterface.play_main_scene.call_deferred()