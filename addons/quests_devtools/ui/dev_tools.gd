@tool
extends Control
class_name DevTools

@export var add_player_to_editable_nodes_checkbox: CheckBox

func _ready() -> void:
	print("Baby Godot Dev Tools active")
	if add_player_to_editable_nodes_checkbox:
		add_player_to_editable_nodes_checkbox.button_pressed = MasterCopyIndicator.add_player_to_editable_nodes

func _click_button() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.reset_progress()

func _toggle_streamlined_exclusive_dock(name: StringName, visible: bool) -> void:
	BabyGodotUtils.toggle_streamlined_exclusive_dock(name, visible)

func _open_level0_clone() -> void:
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")

func _on_check_box_toggled(toggled_on: bool) -> void:
	MasterCopyIndicator.add_player_to_editable_nodes = toggled_on


func _on_coin_button_pressed() -> void:
	GlobalQuests.quests.collect_coin()

func _on_open_master_button_pressed() -> void:
	EditorInterface.open_scene_from_path("res://levels/masters/level0.tscn")

func _on_master_reset_button_pressed() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.stop_game()
		GlobalQuests.quests.reset_progress()
	EditorInterface.open_scene_from_path("res://levels/masters/level0.tscn")
	EditorInterface.save_scene()
	await get_tree().process_frame
	EditorInterface.close_scene()
	await get_tree().process_frame
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")
	await get_tree().process_frame
	EditorInterface.close_scene()
	await get_tree().process_frame
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")


func _on_skip_to_next_checkpoint_button_pressed() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.skip_to_next_checkpoint()

func _on_stop_button_pressed() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.stop_game()


func _on_debug_level_button_pressed() -> void:
	ProjectSettings.set_setting("application/run/main_scene", "res://levels/clones/debug_level.tscn")
	ProjectSettings.save()
	EditorInterface.open_scene_from_path("res://levels/clones/debug_level.tscn")
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Make sure not to commit changes to the main scene!"
	if OS.has_feature("web"):
		dialog.dialog_text = "To reset back to the main level0, you will need to do a hard refresh of the project."
	dialog.title = "Debug Level Selected"
	add_child(dialog)
	dialog.popup_centered()

	
