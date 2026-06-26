@tool
extends EditorPlugin
## This plugin is for developer tools. I guess since the player is also a developer kind of this is like... meta-developer tools.

const panel := preload("res://addons/quests_devtools/ui/dev_tools.tscn")
const master_copy_indicator := preload("res://addons/quests_devtools/ui/master_copy_indicator/master_copy_indicator.tscn")

var panel_instance: DevTools
var master_indicator_instance: MasterCopyIndicator

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	panel_instance = panel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(panel_instance)
	_make_visible(false)

	master_indicator_instance = master_copy_indicator.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, master_indicator_instance)
	scene_changed.connect(func(root: Node):
		master_indicator_instance.scene_changed(root.scene_file_path)
	)
	if get_editor_interface().get_edited_scene_root():
		master_indicator_instance.scene_changed(get_editor_interface().get_edited_scene_root().scene_file_path)
	scene_saved.connect(func(path: String):
		master_indicator_instance.scene_saved(path)
	)

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, master_indicator_instance)

func _has_main_screen():
	return true

func _make_visible(visible):
	if panel_instance:
		panel_instance.visible = visible

func _get_plugin_name():
	return "Baby Godot Dev"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
