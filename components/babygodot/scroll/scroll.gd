@tool
extends Node2D
class_name Scroll

## Emitted when the child condition has been updated. Mainly used to hook up UI/animation changes
signal condition_updated(val: bool)

## Emitted when the scroll is collected. Used for communicating with continuity system, could also be used for collection animations.
signal collected

@export_group("Internal Refs")
## The label that shows the scroll's current unlock condition
@export var label: RichTextLabel

## This is set to true if the Scroll is in an invalid state
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

## A reference to the child `ScrollCondition` object
var condition: ScrollCondition

func _set_error_state() -> void:
	modulate = Color8(200, 0, 0, 200)
	if label:
		label.text = "ERROR!\n\nScroll object needs [code]ScrollCondition[/code] child to work properly."

func _clear_error_state() -> void:
	modulate = Color.WHITE
	if label and condition:
		label.text = condition.get_label_text()

func print_all_properties():
	for prop in get_property_list():
		var prop_name = prop.name
		var prop_value = get(prop_name)
		print(prop_name, ": ", prop_value)

func _ready() -> void:
	if is_instance_of(get_parent(), Viewport):
		print("Ignoring error state check since we're opening the scroll prefab directly")
		return
	condition = BabyGodotUtils.get_first_child_of_type(self, ScrollCondition)
	if not condition:
		error_state = true
		return
	condition.destroyed.connect(func():
		error_state = true
	)
	condition.condition_updated.connect(func(val: bool):
		condition_updated.emit(val)
	)
	condition_updated.emit(condition.is_condition_met())
	_clear_error_state()

## Called when the player collides with the scroll and tries to collect it
func _player_collect() -> void:
	if not condition:
		return
	if condition.is_condition_met():
		collected.emit()
		queue_free()

func _exit_tree() -> void:
	_clear_error_state()
