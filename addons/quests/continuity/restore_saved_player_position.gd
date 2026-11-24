@tool
extends Node
class_name RestoreSavedPlayerPosition
## A utility script that restores the player's last saved position as soon as the scene is loaded. While the player's position is saved in the filesystem by the continuity system while pausing the game, this does not work if quitting out of the game in the middle of play mode. This script helps solve that by restoring the player position from a quit in play mode -> continue flow.

## Whether the game has loaded the player position on startup or not. We only want this logic to run once on startup.
static var _loaded_player_position := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	if not _loaded_player_position:
		_loaded_player_position = true
		GlobalQuests.quests.apply_session_data()
		GlobalQuests.quests.update_player_position(false)
		EditorInterface.save_scene()

