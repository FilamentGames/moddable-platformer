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

## The cost of a hint in coins.
@export var hint_cost := 5

## The prefab to use for editable object indicators.
@export var editable_object_indicator_prefab: PackedScene = preload("res://components/babygodot/editable_object_indicator/editable_object_indicator.tscn")

## Dispatched when the current scene has changed
signal current_scene_updated()

## Dispatched when text in the quest window is updated
signal text_updated()

## Dispatched when a new scroll is collected
signal scroll_collected()

## Dispatched when the player's coins have changed at all
signal coins_changed()

## Dispatched when the player purchases a hint
signal hint_purchased()

## Dispatched when a celebration animation is to be played
signal celebration_animation()

## An object with methods `get_editor_scene`/`set_editor_scene` that provides access to the current editor scene. This should be the main plugin.
var editor_scene_provider

## The scrolls the player has collected in the game.
var scrolls_collected: Array = []

var global_coins: int = 0

var _current_text_line := 0

## The index of the current hint in the list of hints for the current text line. -1 means no hint is currently being shown.
var _current_hint_index := -1

var _last_player_pos: Vector2

## Whether to ignore the player's position while we're forcing it to a specific position.
var _lock_player_position := false

## The quest progress at the last saved checkpoint
var _checkpoint_text_line := 0

var _skipped_checkpoints: Array[NodePath] = []

var _checkpoint_quest_progress: Dictionary = {
	"text_line": 0,
	"global_coins": 0,
	"scrolls_collected": [],
	"last_position": Vector2.ZERO
}

func _init() -> void:
	text_updated.connect(func():
		if text_data[_current_text_line].show_celebration_animation:
			celebration_animation.emit()
	)

## Get the current line of text of the quest
func get_current_text() -> String:
	return text_data[_current_text_line].dialogue_line

func is_current_line_celebration() -> bool:
	return text_data[_current_text_line].show_celebration_animation

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
	if method == QuestLine.ProgressMethod.ScriptTrigger:
		_current_text_line = text_data.find_custom(func(line: QuestLine): return line.progress_method == QuestLine.ProgressMethod.ScriptTrigger, _current_text_line) + 1
	else:
		_current_text_line += 1
	_current_text_line = min(_current_text_line, text_data.size() - 1)
	_current_hint_index = -1
	text_updated.emit()

func skip_to_text_line(line: Variant) -> void:
	var target := -1
	if line is int:
		target = line
	elif line is String:
		target = text_data.find_custom(func(quest_line):
			return quest_line.identifier == line
		)
	if target < 0 or target >= text_data.size():
		return
	_current_text_line = target
	_current_hint_index = -1
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
	_checkpoint_quest_progress = {
		"text_line": _current_text_line,
		"global_coins": global_coins,
		"scrolls_collected": scrolls_collected.duplicate(),
		"last_position": _checkpoint_quest_progress["last_position"]
	}

func load_checkpoint() -> void:
	editor_scene_provider.set_editor_scene()
	_current_text_line = _checkpoint_quest_progress["text_line"]
	global_coins = _checkpoint_quest_progress["global_coins"]
	scrolls_collected = _checkpoint_quest_progress["scrolls_collected"].duplicate()
	scroll_collected.emit()
	text_updated.emit()

func set_inspector_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_inspector_dock_visible(visible)

func set_scene_tree_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_scene_tree_dock_visible(visible)

func set_quest_dock_visible(visible: bool) -> void:
	editor_scene_provider.set_quest_dock_visible(visible)

func hide_bottom_panel() -> void:
	editor_scene_provider.hide_bottom_panel()

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
		var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
		if player:
			_lock_player_position = true
			_last_player_pos = player.get_parent().to_local(target_checkpoint.player_position_marker.global_position)
			update_player_position()
		_checkpoint_quest_progress["last_position"] = _last_player_pos
		target_checkpoint.get_parent().remove_child(target_checkpoint)
		target_checkpoint.free()
		save_checkpoint.call_deferred()

func delete_nodes_in_editor(node_ids: Array, save: bool = true) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var editable_node_list: EditableNodeList = BabyGodotUtils.get_first_child_of_type(scene, EditableNodeList)
	for node_id in node_ids:
		var node: Node = UniqueSceneId.find_by_id(scene, node_id)
		if node:
			if editable_node_list:
				editable_node_list.nodes.erase(node)
			node.get_parent().remove_child(node)
			node.free()
	if editable_node_list:
		## Remove freed nodes from the editable node list, lest we trigger a segfault as it tries to save a freed node reference in the scene.
		var new_editable_nodes := editable_node_list.nodes.filter(func(node): 
			if not node is Node:
				return false
			return node.is_inside_tree()
		)
		editable_node_list.nodes.assign(new_editable_nodes)
	if save:
		editor_scene_provider.update_and_save_node(scene)

func swap_nodes_with_prefabs(swapped_objects: Array[Dictionary]) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	for swapped_object in swapped_objects:
		var parent: Node = UniqueSceneId.find_by_id(scene, swapped_object["parent"])
		var prefab: PackedScene = ResourceLoader.load(swapped_object["prefab"])
		var new_object: Node = prefab.instantiate()
		parent.get_parent().add_child(new_object)
		new_object.owner = scene
		new_object.position = parent.position
		parent.get_parent().remove_child(parent)
		parent.queue_free()

func delete_node_in_editor(node_id: String) -> void:
	delete_nodes_in_editor([node_id])

func collect_coin() -> void:
	global_coins += 1
	coins_changed.emit()

## Resets the player's quest progress. Mainly useful for dev tools.
func reset_progress() -> void:
	_current_text_line = 0
	global_coins = 0
	scrolls_collected.clear()
	text_updated.emit()
	scroll_collected.emit()
	_skipped_checkpoints.clear()

func update_editable_objects(to_add: Array, to_remove: Array) -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var editable_node_list: EditableNodeList = BabyGodotUtils.get_first_child_of_type(scene, EditableNodeList)
	if not editable_node_list:
		return
	for object_id in to_add:
		var object: Node = UniqueSceneId.find_by_id(scene, object_id)
		object.remove_meta("_edit_lock_")
		if editable_node_list.nodes.find(object) == -1:
			editable_node_list.nodes.push_back(object)
	for object_id in to_remove:
		var object: Node = UniqueSceneId.find_by_id(scene, object_id)
		object.set_meta("_edit_lock_", true)
		if editable_node_list.nodes.find(object) != -1:
			editable_node_list.nodes.erase(object)
	var editable_object_indicators := BabyGodotUtils.get_all_children_of_type(scene, EditableObjectIndicator)
	for indicator in editable_object_indicators:
		indicator.get_parent().remove_child(indicator)
		indicator.queue_free()
	for object in editable_node_list.nodes:
		var indicator: EditableObjectIndicator = editable_object_indicator_prefab.instantiate()
		indicator.set_meta("_edit_lock_", true)
		indicator.name = "EditableObjectIndicator"
		object.add_child(indicator)
		indicator.owner = scene
	editor_scene_provider.update_and_save_node(scene)


func get_last_checkpoint_position() -> Vector2:
	return _checkpoint_quest_progress["last_position"]

func can_buy_hint() -> bool:
	return global_coins >= hint_cost and text_data[_current_text_line].hints.size() - 2 >= _current_hint_index

func buy_hint() -> Variant:
	if not can_buy_hint():
		return null
	global_coins -= hint_cost
	coins_changed.emit()
	hint_purchased.emit()
	_current_hint_index += 1
	return text_data[_current_text_line].hints[_current_hint_index]

func deplete_scrolls(quantity: int) -> void:
	for i in quantity:
		scrolls_collected.pop_front()
	scroll_collected.emit()

func skip_to_next_checkpoint() -> void:
	var scene: Node2D = editor_scene_provider.get_editor_scene()
	var player: Player = BabyGodotUtils.get_first_child_of_type(scene, Player)
	if not player:
		return
	var next_checkpoints: Array[Node] = BabyGodotUtils.get_all_children_of_type(scene, Checkpoint)
	if next_checkpoints.is_empty():
		return
	var next_checkpoint = next_checkpoints[0]
	while next_checkpoint and _skipped_checkpoints.has(UniqueSceneId.get_id(next_checkpoint)):
		next_checkpoint = next_checkpoints.pop_front()
	if not next_checkpoint:
		return
	player.position = next_checkpoint.position
	_skipped_checkpoints.push_back(UniqueSceneId.get_id(next_checkpoint))
	editor_scene_provider.update_and_save_node(player)
	editor_scene_provider.set_2d_viewport_focus(player.position, default_editor_zoom)

## An stop feature for dev tools to allow us to do things like reset the whole level. Could be useful for switching levels in a full scope?
func stop_game() -> void:
	editor_scene_provider.stop_game()
