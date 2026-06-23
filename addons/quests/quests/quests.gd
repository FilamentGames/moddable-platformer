@tool
extends Node
class_name BabyGodotQuests
## The singleton object for the global "Quests" system, will store current quest progress

## The list of text lines for the quest. This will probably be replaced with a more robust system that is handled by a resource in the future.
@export var text_data: Array[String] = []

## Dispatched when text in the quest window is updated
signal text_updated()

## An object with methods `get_editor_scene`/`set_editor_scene` that provides access to the current editor scene. This should be the main plugin.
var editor_scene_provider

var _current_text_line := 0

## Get the current line of text of the quest
func get_current_text() -> String:
	return text_data[_current_text_line]

## Move to the next line of text
func next() -> void:
	_current_text_line += 1
	_current_text_line = min(_current_text_line, text_data.size() - 1)
	text_updated.emit()

## If the UI can manually proceed to the next line of text
func can_proceed() -> bool:
	return _current_text_line < text_data.size() - 1

func save_checkpoint() -> void:
	editor_scene_provider.save_editor_scene_as_checkpoint()
	print("Saved checkpoint")

func load_checkpoint() -> void:
	editor_scene_provider.set_editor_scene()
	print("Tried to load checkpoint")

func update_player_position(pos: Vector2) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var flat_scene_children = scene.find_children("*")
	var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
	if player:
		player.position = pos
		editor_scene_provider.update_and_save_node(player)
