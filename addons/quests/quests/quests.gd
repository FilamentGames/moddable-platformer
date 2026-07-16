@tool
extends Node
class_name BabyGodotQuests
## The singleton object for the global "Quests" system, will store current quest progress

## Represents which mode the editor is in
enum EditorMode {
	PLAY, ## Represents play mode
	EDIT ## Represents edit mode
}

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

var _last_player_pos: Vector2

## Whether to ignore the player's position while we're forcing it to a specific position.
var _lock_player_position := false

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
func register_mode_switch(mode: EditorMode = EditorMode.PLAY) -> void:
	var target_mode = QuestLine.ProgressMethod.SwitchToPlay if mode == EditorMode.PLAY else QuestLine.ProgressMethod.SwitchToEdit
	var current_progress_method = text_data[_current_text_line].progress_method
	if current_progress_method == target_mode:
		next(target_mode)
	elif current_progress_method == QuestLine.ProgressMethod.ModeSwitch:
		next(QuestLine.ProgressMethod.ModeSwitch)

func save_checkpoint() -> void:
	editor_scene_provider.save_editor_scene_as_checkpoint()
	_lock_player_position = false
	print("Saved checkpoint")

func load_checkpoint() -> void:
	editor_scene_provider.set_editor_scene()
	print("Tried to load checkpoint")

func set_inspector_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_inspector_dock_visible(visible)

func set_scene_tree_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_scene_tree_dock_visible(visible)

func register_player_position(pos: Vector2) -> void:
	if _lock_player_position:
		return
	_last_player_pos = pos

func update_player_position() -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
	if player:
		player.position = _last_player_pos
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

## Activates a "Knit Witch" checkpoint, replacing the checkpoint trigger with the knit witch NPC in the editor so the checkpoint cannot be triggered again.
func activate_level_checkpoint(checkpoint_id: String) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var target_checkpoint: Checkpoint = UniqueSceneId.find_by_id(scene, checkpoint_id)
	if target_checkpoint:
		var npc: Node2D = target_checkpoint.npc_prefab.instantiate()
		target_checkpoint.get_parent().add_child(npc)
		npc.owner = scene
		npc.position = target_checkpoint.position
		editor_scene_provider.update_and_save_node(scene)
		var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
		if player:
			_lock_player_position = true
			_last_player_pos = player.get_parent().to_local(target_checkpoint.player_position_marker.global_position)
			update_player_position()
		target_checkpoint.get_parent().remove_child(target_checkpoint)
		target_checkpoint.free()
		save_checkpoint.call_deferred()

func delete_node_in_editor(node_id: String) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var node: Node = UniqueSceneId.find_by_id(scene, node_id)
	if node:
		node.get_parent().remove_child(node)
		node.free()
		editor_scene_provider.update_and_save_node(scene)
	else:
		print("Couldn't find node with id ", node_id)

## Resets the player's quest progress. Mainly useful for dev tools.
func reset_progress() -> void:
	_current_text_line = 0
	scrolls_collected = []
	text_updated.emit()
	scroll_collected.emit()
