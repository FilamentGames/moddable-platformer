@tool
extends Control
class_name DevTools

func _ready() -> void:
	print("Baby Godot Dev Tools active")

func _click_button() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.reset_progress()
