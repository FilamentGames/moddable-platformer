extends Node2D
class_name DialogueBox
## A dialogue box for NPC dialogue, partially a simplified implementation of the Threadbare dialogue box.

## The lines of dialogue to show in this dialogue box
@export var dialogue_lines: Array[String]

## If the animated text should stop animating when the next button is clicked.
@export var next_button_stops_animation_first: bool = true

## Whether to always show the next page indicator, even if there are no more lines of dialogue to show.
@export var always_show_next_page_indicator: bool = true

## If the dialogue box's position should be adjusted if it is cut off of the edge of the screen.
@export var adjust_position_if_cut_off: bool = true

@export_group("Internal Refs")
## The label which shows the current line of dialogue
@export var label: RichTextLabel

## The button which progresses dialogue
@export var next_button: Button

## The canvas layer the dialogue box is in
@export var canvas_layer: CanvasLayer

## The sprite that indicates when the text is done animating
@export var corner_idle_sprite: AnimatedSprite2D

## The animation player to wait for page turn animations on
@export var animation_player: AnimationPlayer

## The control that provides the bounding rect for the dialogue box.
@export var bounding_rect_provider: Control

## Emitted once dialogue is done and the dialogue box is queued for deletion
signal finished

## Emitted when the next button is pressed
signal next

func _ready() -> void:
	label.text = ""
	if canvas_layer:
		canvas_layer.offset = global_position
		canvas_layer.visible = true
	if adjust_position_if_cut_off:
		_adjust_position_if_not_fully_on_screen()
	await _play_and_wait_for_animation(&"appear")
	_get_next_text()

## Loads the next text or queues for deletion when there is no more text to fetch
func _get_next_text() -> void:
	if dialogue_lines.size() == 0:
		await _play_and_wait_for_animation(&"disappear")
		finished.emit()
		queue_free()
		return
	label.text = dialogue_lines.pop_front()
	if animation_player:
		animation_player.play(&"RESET")

## Function wired up to be called when the next button is clicked
func _on_next_button_click():
	if next_button_stops_animation_first and label is AnimatedLabel:
		var animated_label: AnimatedLabel = label as AnimatedLabel
		if animated_label.is_animating():
			animated_label.show_all()
			return
	if _is_next_page():
		await _play_and_wait_for_animation(&"next_page")
	next.emit()
	_get_next_text()

func _on_dialogue_text_end_animating() -> void:
	if corner_idle_sprite and (always_show_next_page_indicator or _is_next_page()):
		corner_idle_sprite.visible = true
		corner_idle_sprite.play(&"default")

func _is_next_page() -> bool:
	return dialogue_lines.size() != 0

func _on_dialogue_text_start_animating() -> void:
	if corner_idle_sprite:
		corner_idle_sprite.stop()
		corner_idle_sprite.visible = false

func _play_and_wait_for_animation(animation_name: StringName) -> void:
	if animation_player:
		animation_player.play(animation_name)
		await animation_player.animation_finished

func _on_panel_gui_input(event: InputEvent, panel: NodePath) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not event.pressed:
			var control: Control = get_node(panel)
			control.accept_event()
			_on_next_button_click()

## Adjusts the position of the dialogue box if it is not fully on screen.
func _adjust_position_if_not_fully_on_screen() -> void:
	var camera_rect := get_camera_rect()
	var bounding_rect := get_bounding_rect()
	if not camera_rect.encloses(bounding_rect):
		if bounding_rect.position.x < camera_rect.position.x:
			global_position.x -= camera_rect.position.x
		if bounding_rect.position.y < camera_rect.position.y:
			global_position.y -= camera_rect.position.y
		if bounding_rect.position.x + bounding_rect.size.x > camera_rect.position.x + camera_rect.size.x:
			global_position.x -= camera_rect.position.x + camera_rect.size.x - bounding_rect.size.x
		if bounding_rect.position.y + bounding_rect.size.y > camera_rect.position.y + camera_rect.size.y:
			global_position.y -= camera_rect.position.y + camera_rect.size.y - bounding_rect.size.y
		canvas_layer.offset = global_position
	
## Gets the camera rect for the dialogue box. This can be overridden in tests.
func get_camera_rect() -> Rect2:
	var viewport_rect = get_viewport_rect()
	var canvas_transform = get_canvas_transform()
	return Rect2(-canvas_transform.origin / canvas_transform.get_scale(), viewport_rect.size / canvas_transform.get_scale())

## Gets the bounding rect for the dialogue box. This can be overridden in tests.
func get_bounding_rect() -> Rect2:
	var bounding_rect = bounding_rect_provider.get_global_rect()
	bounding_rect.position += canvas_layer.offset
	return bounding_rect