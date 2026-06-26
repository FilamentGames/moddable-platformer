@tool
extends EditorPlugin
## This plugin is for developer tools. I guess since the player is also a developer kind of this is like... meta-developer tools.

const panel := preload("res://addons/quests_devtools/ui/dev_tools.tscn")

var panel_instance: DevTools

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

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _has_main_screen():
	return true

func _make_visible(visible):
	if panel_instance:
		panel_instance.visible = visible

func _get_plugin_name():
	return "Baby Godot Dev"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
