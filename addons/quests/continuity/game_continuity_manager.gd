extends Node
class_name GameContinuityManager
## Registers the state of things in-game so that they persist into the editor after the game is closed.

## If a player object has been registered
var _player_registered := false

## A reference to the current player object
var _player: Node2D

## The last known position of the player
var _last_player_pos: Vector2

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
	tree_exited.connect(_on_delete)
	InGameQuestsBridge.register_mode_switch()

func _process(delta: float) -> void:
	if not _player:
		return
	_last_player_pos = _player.position

## Run this function on delete
func _on_delete() -> void:
	InGameQuestsBridge.save_player_position(get_player_objects_last_position())
	InGameQuestsBridge.register_mode_switch()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _player:
			_on_delete()
