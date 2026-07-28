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

## This control displays the hint for the current text.
@export var hint_display: HintDisplay

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
	next_button.pressed.connect(next)
	if save_checkpoint_button:
		save_checkpoint_button.pressed.connect(save_checkpoint)
	if load_checkpoint_button:
		load_checkpoint_button.pressed.connect(load_checkpoint)

func update_text():
	text.text = quests_provider.get_current_text()
	_update_next_button_state()
	hint_display.hide()
	_update_hint_button_state()

func next():
	quests_provider.next()
	_update_next_button_state()

func _update_hint_button_state():
	if hint_button:
		hint_button.disabled = not quests_provider.can_buy_hint()

func _update_next_button_state():
	next_button.disabled = !quests_provider.can_proceed()

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
	if animated_sprite:
		animated_sprite.play(sprite_animation_name)

func _on_quest_text_end_animating() -> void:
	if animated_sprite:
		animated_sprite.stop()
