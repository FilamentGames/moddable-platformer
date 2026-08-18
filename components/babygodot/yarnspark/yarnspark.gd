@tool
extends Node2D
class_name Collectible
## The collectibles needed to open gates.

## Emitted when the child condition has been updated. Mainly used to hook up UI/animation changes
signal condition_updated(val: bool)

## Emitted when the scroll is collected. Used for communicating with continuity system, could also be used for collection animations.
signal collected

@export_group("Internal Refs")
## The label that shows the scroll's current unlock condition
@export var label: RichTextLabel

## The info indicator that is used to show the scroll's information.
@export var info_indicator: InfoIndicator

## If the yarnspark has been collected and is just animating out
var _is_collected := false

var _bridge: InGameQuestsBridge

## This is set to true if the Collectible is in an invalid state
var error_state := false:
	get:
		return _internal_err_state
	set(val):
		if val:
			_set_error_state()
		else:
			_clear_error_state()
		_internal_err_state = val

var _internal_err_state := false

var _last_condition_state := false

## A reference to the child `CollectibleCondition` object
var condition: CollectibleCondition

func _set_error_state() -> void:
	modulate = Color(200.0/255, 0, 0, 200.0/255)
	if label:
		label.text = "ERROR!\n\nObject needs [code]CollectibleCondition[/code] child to work properly."

func _clear_error_state() -> void:
	modulate = Color.WHITE
	if label and condition:
		label.text = condition.get_label_text()

func _ready() -> void:
	if Engine.is_editor_hint():
		info_indicator._on_activate()
	if is_instance_of(get_parent(), Viewport):
		print("Ignoring error state check since we're opening the prefab directly")
		return
	condition = BabyGodotUtils.get_first_child_of_type(self, CollectibleCondition)
	if not condition:
		error_state = true
		return
	condition.destroyed.connect(func():
		error_state = true
	)
	condition.condition_updated.connect(func(val: bool):
		if _last_condition_state == val:
			return
		_last_condition_state = val
		condition_updated.emit(val)
	)
	condition_updated.emit(condition.is_condition_met())
	_clear_error_state()

	if not _bridge and not Engine.is_editor_hint():
		_bridge = InGameQuestsBridge.new()

		_bridge.game_unpaused.connect(func():
			condition_updated.emit(condition.is_condition_met())
		)

## Called when the player collides with the scroll and tries to collect it
func _player_collect() -> void:
	if not condition or _is_collected:
		return
	if condition.is_condition_met():
		_is_collected = true
		collected.emit()

func _collection_animation_done() -> void:
	queue_free()

func _exit_tree() -> void:
	_clear_error_state()
