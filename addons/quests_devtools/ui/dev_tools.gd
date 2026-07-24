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