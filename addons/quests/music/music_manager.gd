@tool
extends Node
class_name MusicManager
## Handles playing music in the editor and switching between play/edit mode tracks.

@export var play_mode_track: AudioStreamPlayer

@export var edit_mode_track: AudioStreamPlayer

@export_range(0.1, 5.0, 0.1, "suffix:s") var crossfade_duration: float = 1.0

var _crossfade_tween: Tween

enum Mode {
	PLAY_MODE,
	EDIT_MODE
}

func _ready() -> void:
	play_mode_track.volume_linear = 0
	edit_mode_track.volume_linear = 1

	play_mode_track.play()
	edit_mode_track.play()

## Crossfades tracks to the correct volume.
func crossfade_tracks(mode: Mode) -> void:
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()

	var play_volume: float = 1.0 if mode == Mode.PLAY_MODE else 0.0
	var edit_volume: float = 1.0 if mode == Mode.EDIT_MODE else 0.0

	if not play_mode_track.playing:
		play_mode_track.play()
	if not edit_mode_track.playing:
		edit_mode_track.play()

	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)
	_crossfade_tween.set_trans(Tween.TRANS_LINEAR)
	_crossfade_tween.tween_property(play_mode_track, "volume_linear", play_volume, crossfade_duration)
	_crossfade_tween.tween_property(edit_mode_track, "volume_linear", edit_volume, crossfade_duration)
