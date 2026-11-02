extends RefCounted
class_name CheckpointPlayerWatcher
## Extracted out of SceneDelta to keep the class cleaner

var _player_position := Vector2(0, 0)

var _player: Player

var _editor_scene: Node

func _init(editor_scene: Node) -> void:
	_editor_scene = editor_scene

func _get_player() -> Player:
	return BabyGodotUtils.get_first_child_of_type(_editor_scene, Player)

func get_player_position() -> Vector2:
	if not _player:
		_player = _get_player()
	return _player.global_position

func take_player_snapshot() -> void:
	_player_position = get_player_position()

func apply_player_snapshot() -> void:
	if not _player:
		return
	_player.global_position = _player_position

func export() -> Vector2:
	return _player_position

func import(pos: Vector2) -> void:
	_player_position = pos