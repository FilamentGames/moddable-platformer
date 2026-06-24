@abstract
@tool
extends Node
class_name ScrollCondition
## An abstract class that represents an individual scroll's condition that needs to be satisfied to be collected

## Returns the text that is displayed in the scroll's condition label. This field supports BBCode.
@abstract func get_label_text() -> String

## Returns true if the condition is satisfied and the scroll can be collected. False if otherwise.
@abstract func is_condition_met() -> bool

## Emitted when the `is_condition_met` value has flipped. Can be manually emitted in tests to simulate editor behaviors
signal condition_updated(val: bool)

## Emitted when the object is deleted. This can help the editor detect an invalid state.
signal destroyed

func _ready() -> void:
	if Engine.is_editor_hint():
		var inspector = EditorInterface.get_inspector()
		var tree = EditorInterface.get_edited_scene_root()
		tree.child_entered_tree.connect(_on_editor_update)
		inspector.property_edited.connect(_on_editor_update)
		GlobalQuests.quests.current_scene_updated.connect(_on_editor_update.bind(true))
	_on_editor_update(true)

func _exit_tree() -> void:
	destroyed.emit()

func _on_editor_update(_arg: Variant) -> void:
	condition_updated.emit(is_condition_met())
