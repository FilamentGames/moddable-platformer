@tool
extends Control
class_name BabyGodotQuestDock

## The Label control that displays the current quest text
@export var text: Label

@export_group("Sprite Refs")
## An animated sprite to animate while the text is animating
@export var animated_sprite: AnimatedSprite2D

## The animation to play on the animated sprite
@export var sprite_animation_name: StringName = &"default"

@export_group("Progress + Checkpoint Refs")
## The Button control that moves to the next step. This might end up being a debug-only control?
@export var next_button: Button

## This button saves the current checkpoint, only used for debugging purposes.
@export var save_checkpoint_button: Button

## This button loads the last checkpoint.
@export var load_checkpoint_button: Button

@export_group("Hint Refs")
## This button buys a hint for the current text.
@export var hint_button: Button

@export var hint_button_text_template: String = "Get a Hint (-%d Coins)"

## This control displays the hint for the current text.
@export var hint_display: HintDisplay

## Bubbled up from the Quests event
signal celebration_animation()

## If the celebration animation is playing
var _play_celebration_animation := false

## The instance of BabyGodotQuests object we're getting data from.
var quests_provider: BabyGodotQuests

func _enter_tree() -> void:
	if !quests_provider:
		quests_provider = GlobalQuests.quests
	if !text || !quests_provider:
		return
	update_text()
	_update_hint_button_state()
	quests_provider.text_updated.connect(update_text)
	quests_provider.coins_changed.connect(_update_hint_button_state)
	quests_provider.celebration_animation.connect(_activate_celebration)
	next_button.pressed.connect(next)
	if save_checkpoint_button:
		save_checkpoint_button.pressed.connect(save_checkpoint)
	if load_checkpoint_button:
		load_checkpoint_button.pressed.connect(load_checkpoint)

func _exit_tree():
	quests_provider.text_updated.disconnect(update_text)
	quests_provider.coins_changed.disconnect(_update_hint_button_state)
	quests_provider.celebration_animation.disconnect(_activate_celebration)
	next_button.pressed.disconnect(next)
	if save_checkpoint_button:
		save_checkpoint_button.pressed.disconnect(save_checkpoint)
	if load_checkpoint_button:
		load_checkpoint_button.pressed.disconnect(load_checkpoint)

func update_text():
	_play_celebration_animation = quests_provider.is_current_line_celebration()
	text.text = quests_provider.get_current_text()
	_update_next_button_state()
	hint_display.hide()
	_update_hint_button_state()

func next():
	quests_provider.next()
	_update_next_button_state()

func _update_hint_button_state():
	hint_button.text = hint_button_text_template % quests_provider.hint_cost
	if hint_button:
		hint_button.disabled = not quests_provider.can_buy_hint()

func _update_next_button_state():
	next_button.disabled = !quests_provider.can_proceed()

func _activate_celebration():
	_play_celebration_animation = true

func save_checkpoint():
	quests_provider.save_checkpoint()

func load_checkpoint():
	var dialog := ConfirmationDialog.new()
	dialog.title = "Reset World"
	dialog.dialog_text = "Are you sure you want to reset the world? You will lose any edits you have made since the last checkpoint."

	dialog.confirmed.connect(func():
		quests_provider.load_checkpoint()
	)

	add_child(dialog)
	dialog.popup_centered()
	dialog.show()

func buy_hint():
	var hint = quests_provider.buy_hint()
	if hint:
		hint_display.set_hint(hint)
		hint_display.show()
	else:
		hint_display.hide()
	_update_hint_button_state()

func _on_quest_text_start_animating() -> void:
	await get_tree().process_frame
	if not animated_sprite:
		return
	if _play_celebration_animation:
		celebration_animation.emit()
	else:
		animated_sprite.play(sprite_animation_name)

func _on_quest_text_end_animating() -> void:
	await get_tree().process_frame
	if animated_sprite and not _play_celebration_animation:
		animated_sprite.stop()

func _on_celebration_animation_component_done() -> void:
	_play_celebration_animation = false
	animated_sprite.play(sprite_animation_name)
	animated_sprite.stop()
