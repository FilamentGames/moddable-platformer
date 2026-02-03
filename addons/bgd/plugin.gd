@tool
extends EditorPlugin

var quest_dock: Control

func _enter_tree():
	print("Baby Godot plugin enabled")
	
	# Load and instantiate the quest dock scene
	var quest_dock_scene = load("res://addons/bgd/quest_dock.tscn")
	if quest_dock_scene:
		quest_dock = quest_dock_scene.instantiate()
		# Add the dock to the bottom panel (with the debugger, output, etc.)
		add_control_to_bottom_panel(quest_dock, "Quest")

	else:
		push_error("Failed to load quest_dock.tscn")

func _exit_tree():
	print("Baby Godot plugin disabled")
	
	# Remove the dock when plugin is disabled
	if quest_dock:
		remove_control_from_bottom_panel(quest_dock)
		quest_dock.queue_free()
		quest_dock = null
