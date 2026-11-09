@tool
extends EditorPlugin
## This plugin is for the Baby Godot title screen.

const title_screen = preload("res://addons/babygo_title_screen/ui/titlescreen.tscn")

var title_screen_instance: BabyGodotTitleScreen

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	title_screen_instance = title_screen.instantiate()
	EditorInterface.get_editor_main_screen().add_child(title_screen_instance)
	_make_visible(false)

	title_screen_instance.main_screen_reference = self

	get_editor_interface().set_main_screen_editor("Title Screen")

func _exit_tree() -> void:
	EditorInterface.get_editor_main_screen().remove_child(title_screen_instance)
	title_screen_instance.queue_free()

func _make_visible(visible):
	if title_screen_instance:
		title_screen_instance.visible = visible

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Title Screen"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("GodotMonochrome", "EditorIcons")

func disable_title() -> void:
	_make_visible(false)
	EditorInterface.set_main_screen_editor("2D")
	# TODO: Customize streamlined editor to be able to actually hide this plugin