@tool
extends EditorPlugin

var quest_dock: EditorDock

func _enter_tree():
	print("Baby Godot plugin enabled")
	
	var quest_dock_scene = load("res://addons/bgd/quest_dock.tscn")
	quest_dock = EditorDock.new()
	quest_dock.title = "Quest"
	quest_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	var quest_dock_content = quest_dock_scene.instantiate()
	quest_dock.add_child(quest_dock_content)
	add_dock(quest_dock)


func _exit_tree():
	print("Baby Godot plugin disabled")
	
	# Remove the dock when plugin is disabled
	if quest_dock:
		remove_dock(quest_dock)
		quest_dock.queue_free()
