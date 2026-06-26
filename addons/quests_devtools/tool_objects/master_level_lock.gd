extends Node
class_name MasterLevelLock
## Prevents a level from being run in the game so we don't accidentally undo making a level.

## This allows us to disable the assertion. Only set this to true in unit testing configurations.
static var skip_assert := false

func _init() -> void:
	if Engine.is_editor_hint():
		# This is allowed to exist in editor
		return
	if not skip_assert:
		assert(false, "You are trying to play the master copy of a level. Please play the clone copy.")
