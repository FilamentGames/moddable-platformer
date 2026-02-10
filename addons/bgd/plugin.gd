@tool
extends EditorPlugin

var quest_dock_scene: Control

func _enter_tree():
	print("Baby Godot plugin enabled")
	
	quest_dock_scene = load("res://addons/bgd/quest_dock.tscn").instantiate()
	add_control_to_container(CONTAINER_CANVAS_EDITOR_BOTTOM, quest_dock_scene)
	# quest_dock = EditorDock.new()
	# quest_dock.title = "Quest"
	# quest_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	# var quest_dock_content = quest_dock_scene.instantiate()
	# quest_dock.add_child(quest_dock_content)
	# add_dock(quest_dock)


func _exit_tree():
	print("Baby Godot plugin disabled")
	
	# Remove the dock when plugin is disabled
	if quest_dock_scene:
		remove_control_from_container(CONTAINER_CANVAS_EDITOR_BOTTOM, quest_dock_scene)
		quest_dock_scene.queue_free()
		#remove_dock(quest_dock)
		#quest_dock.queue_free()
