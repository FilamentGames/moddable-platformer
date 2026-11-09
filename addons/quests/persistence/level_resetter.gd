@tool
extends Node
class_name LevelResetter
## Helper class that handles resetting levels.

const BACKUP_DIRECTORY := "res://levels/.backups"
const CLONE_DIRECTORY := "res://levels/clones"

static var instance: LevelResetter

func _ready() -> void:
	instance = self

## Resets all clone levels back to their initial state
func reset_levels() -> void:
	var backup_dir := DirAccess.open(BACKUP_DIRECTORY)
	if backup_dir:
		_do_production_reset(backup_dir)
	else:
		_do_dev_tools_reset()

## This is fallback logic if the `backups` directory doesn't exist. Should only happen to developers.
func _do_dev_tools_reset() -> void:
	EditorInterface.open_scene_from_path("res://levels/masters/level0.tscn")
	EditorInterface.save_scene()
	await get_tree().process_frame
	EditorInterface.close_scene()
	await get_tree().process_frame
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")
	await get_tree().process_frame
	EditorInterface.close_scene()
	await get_tree().process_frame
	EditorInterface.open_scene_from_path("res://levels/clones/level0.tscn")

## Copies the levels in the backups directory to their correct place.
func _do_production_reset(backup_dir: DirAccess) -> void:
	backup_dir.include_hidden = false
	backup_dir.include_navigational = false
	backup_dir.list_dir_begin()
	var entry := backup_dir.get_next()
	while entry != "":
		var source := BACKUP_DIRECTORY.path_join(entry)
		if FileAccess.file_exists(source):
			var destination := CLONE_DIRECTORY.path_join(entry)
			var result := DirAccess.copy_absolute(source, destination)
			if result != OK:
				push_error(
					"LevelResetter: failed to copy %s to %s (error %s)" % [source, destination, result]
				)
		entry = backup_dir.get_next()
	backup_dir.list_dir_end()