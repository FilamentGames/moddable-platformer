@tool
extends EditorPlugin

## Holds the dock for the lifetime of the plugin
var dock: EditorDock

## Holds the actual scene contained within the dock
var dock_scene: BabyGodotQuestDock

## Holds the instance of the quests bridge debugger plugin
var bridge: BabyGodotQuestsBridge

var checkpoints: CheckpointHelper = CheckpointHelper.new()

const global_message_service_name = "GlobalMessagingService"

func _enable_plugin() -> void:
	add_autoload_singleton(global_message_service_name, "res://addons/quests/bridge/editor_game_messaging_service.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton(global_message_service_name)

func save_editor_scene_as_checkpoint() -> void:
	checkpoints.save_editor_scene_as_checkpoint()

func set_editor_scene() -> void:
	checkpoints.set_editor_scene()

func _enter_tree() -> void:
	checkpoints.plugin = self

	var quests: BabyGodotQuests = preload("res://addons/quests/quests/quests.tscn").instantiate()
	quests.editor_scene_provider = self
	GlobalQuests.quests = quests
	dock_scene = preload("res://addons/quests/quest_dock/quest_dock.tscn").instantiate()

	dock = EditorDock.new()
	dock.add_child(dock_scene)
	dock.title = "Quest"
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	dock.available_layouts = EditorDock.DOCK_LAYOUT_ALL

	add_dock(dock)

	bridge = BabyGodotQuestsBridge.new()
	add_debugger_plugin(bridge)

func _exit_tree() -> void:
	remove_debugger_plugin(bridge)
	remove_dock(dock)
	dock.queue_free()
