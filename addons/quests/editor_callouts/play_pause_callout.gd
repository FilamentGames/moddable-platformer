@tool
extends Node2D
class_name PlayPauseCallout
## Shows an animation to call attention to the play/pause button. Only works in the streamlined editor.

@export_group("Internal Refs")
@export var timer: Timer
@export var border_rect: ReferenceRect
@export var animation_player: AnimationPlayer

var run_bar: MarginContainer
var play_button: Button
var pause_button: Button

## Binds this component to the correct location in the editor.
func bind_to_editor():
	if EditorInterface.has_method("get_editor_run_bar"):
		run_bar = EditorInterface["get_editor_run_bar"].call()
		visible = false
		play_button = run_bar.get_child(0).get_child(1).get_child(0).get_child(0)
		pause_button = run_bar.get_child(0).get_child(1).get_child(0).get_child(1)
		run_bar.add_child(self)
	else:
		print("`get_editor_run_bar` not available in this version of Godot. Play/pause callout will not be visible.")
		queue_free()

func make_visible() -> void:
	timer.start()

func _do_make_visible() -> void:
	timer.stop()
	global_position = play_button.global_position
	if border_rect:
		global_position -= Vector2(border_rect.border_width, border_rect.border_width)
	if animation_player:
		animation_player.play("callout_idle")
	visible = true

func hide() -> void:
	visible = false

func recursive_print_children(node: Node, parent_path: String = "") -> void:
	print(parent_path + node.name)
	if node is Button:
		var button := node as Button
		print(button.tooltip_text)
	for child in node.get_children():
		recursive_print_children(child, parent_path + node.name + "/")

func _ready() -> void:
	if not run_bar:
		return
	GlobalQuests.quests.tag_reached.connect(func(tag: String):
		if tag == "show_pause_callout" or tag == "show_play_callout":
			make_visible()
	)
	GlobalQuests.quests.mode_switched.connect(func():
		hide()
		timer.stop()
	)
	timer.timeout.connect(_do_make_visible)
