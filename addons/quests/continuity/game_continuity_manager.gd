extends Node
class_name GameContinuityManager
## Registers the state of things in-game so that they persist into the editor after the game is closed.

## If a player object has been registered
var _player_registered := false

## A reference to the current player object
var _player: Node2D

## The last known position of the player
var _last_player_pos: Vector2

## The last known played scene
var _last_played_scene: String

## Registers the current player object
func register_player_object(player: Node2D) -> void:
	_player_registered = true
	_player = player

## Gets the player object's last detected position
func get_player_objects_last_position() -> Vector2:
	if not _player_registered:
		return Vector2.INF
	return _last_player_pos

func _ready() -> void:
	if !get_tree().current_scene:
		## Disable the autoload singleton in tests
		queue_free()
		return
	_update_last_played_scene()
	tree_exited.connect(_on_delete)
	InGameQuestsBridge.set_current_edited_scene(_last_played_scene)
	InGameQuestsBridge.register_mode_switch(BabyGodotQuests.EditorMode.PLAY)

func _process(delta: float) -> void:
	if not _player:
		return
	_last_player_pos = _player.position
	_update_last_played_scene()
	InGameQuestsBridge.set_current_edited_scene(_last_played_scene)
	InGameQuestsBridge.save_player_position(get_player_objects_last_position())

func _update_last_played_scene() -> void:
	_last_played_scene = get_tree().current_scene.scene_file_path

## Run this function on delete
func _on_delete() -> void:
	InGameQuestsBridge.set_current_edited_scene(_last_played_scene)
	InGameQuestsBridge.save_player_position(get_player_objects_last_position())

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _player:
			_on_delete()
