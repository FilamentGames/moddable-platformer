@tool
extends Node
class_name BabyGodotQuests
## The singleton object for the global "Quests" system, will store current quest progress

## The list of text lines for the quest. This will probably be replaced with a more robust system that is handled by a resource in the future.
@export var text_data: Array[QuestLine] = []

## The zoom level to reset to when the player jumps from game mode back to editor mode.
@export var default_editor_zoom := 0.5

## Dispatched when the current scene has changed
signal current_scene_updated()

## Dispatched when text in the quest window is updated
signal text_updated()

## Dispatched when a new scroll is collected
signal scroll_collected()

## An object with methods `get_editor_scene`/`set_editor_scene` that provides access to the current editor scene. This should be the main plugin.
var editor_scene_provider

## The scrolls the player has collected in the game.
var scrolls_collected: Array[String]

var _current_text_line := 0

## Get the current line of text of the quest
func get_current_text() -> String:
	return text_data[_current_text_line].dialogue_line

## Get all upcoming lines that can be read with just the Next Button
func get_all_nextbutton_quest_text() -> Array[String]:
	var array: Array[String] = []
	var i := _current_text_line
	while i < text_data.size() - 1 and text_data[i].progress_method == QuestLine.ProgressMethod.NextButton:
		array.push_back(text_data[i].dialogue_line)
		i += 1
	array.push_back(text_data[i].dialogue_line)
	return array
	
	
## Move to the next line of text
func next(method := QuestLine.ProgressMethod.NextButton) -> void:
	if text_data[_current_text_line].progress_method != QuestLine.ProgressMethod.NextButton and text_data[_current_text_line].progress_method != method:
		return
	_current_text_line += 1
	_current_text_line = min(_current_text_line, text_data.size() - 1)
	text_updated.emit()

## If the UI can manually proceed to the next line of text
func can_proceed() -> bool:
	return _current_text_line < text_data.size() - 1 && text_data[_current_text_line].progress_method == QuestLine.ProgressMethod.NextButton

## Register a mode switch, and progress quest text if it's currently waiting for a mode switch
func register_mode_switch() -> void:
	if text_data[_current_text_line].progress_method == QuestLine.ProgressMethod.ModeSwitch:
		next(QuestLine.ProgressMethod.ModeSwitch)

func save_checkpoint() -> void:
	editor_scene_provider.save_editor_scene_as_checkpoint()
	print("Saved checkpoint")

func load_checkpoint() -> void:
	editor_scene_provider.set_editor_scene()
	print("Tried to load checkpoint")

func set_inspector_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_inspector_dock_visible(visible)

func update_player_position(pos: Vector2) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
	if player:
		player.position = pos
		editor_scene_provider.update_and_save_node(player)
		editor_scene_provider.set_2d_viewport_focus(player.position, default_editor_zoom)
	else:
		print("Couldn't find player object")

func set_current_edited_scene(path: String) -> void:
	editor_scene_provider.set_current_edited_scene(path)

func collect_scroll(scroll_id: String) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var target_scroll := UniqueSceneId.find_by_id(scene, scroll_id)
	if target_scroll:
		target_scroll.get_parent().remove_child(target_scroll)
		target_scroll.free()
		editor_scene_provider.update_and_save_node(scene)
		scrolls_collected.push_back(scroll_id)
		scroll_collected.emit()

## Resets the player's quest progress. Mainly useful for dev tools.
func reset_progress() -> void:
	_current_text_line = 0
	scrolls_collected = []
	text_updated.emit()
	scroll_collected.emit()
