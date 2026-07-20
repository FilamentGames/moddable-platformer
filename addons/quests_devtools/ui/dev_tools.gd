@tool
extends Control
class_name DevTools

func _ready() -> void:
	print("Baby Godot Dev Tools active")

func _click_button() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.reset_progress()

func _toggle_streamlined_exclusive_dock(name: StringName, visible: bool) -> void:
	BabyGodotUtils.toggle_streamlined_exclusive_dock(name, visible)


func _open_level0_clone() -> void:
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")
