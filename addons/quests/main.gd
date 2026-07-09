@tool
extends EditorPlugin

## Holds the dock for the lifetime of the plugin
var dock: EditorDock

## Holds the actual scene contained within the dock
var dock_scene: BabyGodotQuestDock

## Holds the instance of the quests bridge debugger plugin
var bridge: BabyGodotQuestsBridge

var checkpoints := CheckpointHelper.new()

const global_message_service_name = "GlobalMessagingService"
const game_continuity_service_name = "GlobalContinuityManager"

func _enable_plugin() -> void:
	add_autoload_singleton(global_message_service_name, "res://addons/quests/bridge/editor_game_messaging_service.gd")
	add_autoload_singleton(game_continuity_service_name, "res://addons/quests/continuity/game_continuity_manager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton(global_message_service_name)
	remove_autoload_singleton(game_continuity_service_name)

func save_editor_scene_as_checkpoint() -> void:
	checkpoints.save_editor_scene_as_checkpoint()

func get_editor_scene():
	return EditorInterface.get_edited_scene_root()

func get_editor_viewport_2d() -> SubViewport:
	return EditorInterface.get_editor_viewport_2d()

func set_editor_scene() -> void:
	checkpoints.set_editor_scene()

func update_and_save_node(node: Node) -> void:
	EditorInterface.set_object_edited(node, true)
	EditorInterface.save_scene()

func set_inspector_dock_visible(visible: bool) -> void:
	BabyGodotUtils.toggle_streamlined_exclusive_dock("get_inspector_dock", visible)

func set_2d_viewport_focus(position: Vector2, zoom: float) -> void:
	# EditorInterface.get_canvas_item_editor only exists in our customized version of
	# Godot, so avoid an error by checking for the method ahead of time.
	var interface = EditorInterface
	if interface.has_method("get_canvas_item_editor"):
		var canvas_item_editor = interface.get_canvas_item_editor()
		canvas_item_editor.set_viewport_focus(position, zoom)
	else:
		print("Tried to center camera in viewport, but can't!")
		pass # Do nothing

func set_current_edited_scene(path: String) -> void:
	EditorInterface.open_scene_from_path(path)

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

	_connect_scene_edit_signal()

	bridge = BabyGodotQuestsBridge.new()
	add_debugger_plugin(bridge)

	BabyGodotUtils.toggle_streamlined_exclusive_dock("get_inspector_dock", false)
	BabyGodotUtils.toggle_streamlined_exclusive_dock("get_scene_tree_dock", false)

func _connect_scene_edit_signal() -> void:
	scene_changed.connect(func(_arg: Variant):
		GlobalQuests.quests.current_scene_updated.emit()
	)

func _exit_tree() -> void:
	remove_debugger_plugin(bridge)
	remove_dock(dock)
	dock.queue_free()
