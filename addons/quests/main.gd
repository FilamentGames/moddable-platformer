@tool
extends EditorPlugin

## Holds the dock for the lifetime of the plugin
var dock: EditorDock

## Holds the actual scene contained within the dock
var dock_scene: BabyGodotQuestDock

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	var quests: BabyGodotQuests = preload("res://addons/quests/quests/quests.tscn").instantiate()
	GlobalQuests.quests = quests
	dock_scene = preload("res://addons/quests/quest_dock/quest_dock.tscn").instantiate()

	dock = EditorDock.new()
	dock.add_child(dock_scene)
	dock.title = "Quest"
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	dock.available_layouts = EditorDock.DOCK_LAYOUT_ALL

	add_dock(dock)

func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
