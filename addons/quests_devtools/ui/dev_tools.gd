@tool
extends Control
class_name DevTools

func _ready() -> void:
	print("Baby Godot Dev Tools active")

func _click_button() -> void:
	if GlobalQuests and GlobalQuests.quests:
		GlobalQuests.quests.reset_progress()
		
func _get_streamlined_exclusive_dock(name: StringName):
	var interface = EditorInterface
	if interface.has_method(name):
		return interface.call(name)
	else:
		return null


func _toggle_streamlined_exclusive_dock(name: StringName, visible: bool) -> void:
	var dock: EditorDock = _get_streamlined_exclusive_dock(name)
	if dock:
		dock.open() if visible else dock.close()
	else:
		# Print a message to the output window so we know it would have worked in streamlined Godot
		var verb := "open" if visible else "close"
		print("Tried to " + verb + " the dock via `" + name + "` but it's not possible in this version of Godot!")
