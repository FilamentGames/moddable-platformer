extends Node2D
class_name Npc
## An NPC that can spawn dialogue if the player hits the "action" button next to them.

## The lines of dialogue this NPC says.
@export var dialogue_lines: Array[String]

## If enabled, bypass the `dialogue_lines` field and show the current Quest dialogue line instead.
@export var use_global_quest_dialogue := false

@export_group("Internal Refs")
## The triggerable area for the NPC.
@export var player_detector: Area2D

## The node in which the dialogue box is appended as a child to.
@export var dialogue_container: Node2D

## The dialogue box prefab to instantiate
var dialogue_box_prefab: PackedScene = preload("res://components/babygodot/dialogue_box/dialogue_box.tscn")

## A reference to the last spawned dialogue box
var current_dialogue_box: DialogueBox

var bridge: InGameQuestsBridge

func _ready() -> void:
	if not use_global_quest_dialogue:
		return
	if not bridge:
		bridge = InGameQuestsBridge.new()
	bridge.all_nextbutton_quest_text.connect(func(text: Array[String]):
		dialogue_lines = text.duplicate()
	)
	bridge.quest_text.connect(func(_text):
		bridge.request_all_nextbutton_quest_text()
	)
	bridge.request_all_nextbutton_quest_text()
		

## Tries to find the `PlayerDialogueComponent` child of `player` and then passes it to a callable if it exists.
func _get_player_dialogue_component_and(player: Node, fn: Callable) -> void:
	var component: PlayerDialogueComponent = BabyGodotUtils.get_first_child_of_type(player, PlayerDialogueComponent)
	if component:
		fn.call(component)
	else:
		print_debug("No PlayerDialogueComponent Detected")

## This is run when a body enters the player detector
func _player_entered(player: CharacterBody2D):
	_get_player_dialogue_component_and(player, func(component: PlayerDialogueComponent):
		component.dialogue_zones.push_back(self)
	)

## This is run when a body exits the player detector
func _player_exited(player: CharacterBody2D):
	_get_player_dialogue_component_and(player, func(component: PlayerDialogueComponent):
		var index := component.dialogue_zones.rfind(self)
		component.dialogue_zones.remove_at(index)
	)

## Spawns a dialogue box for this NPC's dialogue
func spawn_dialogue_box(player_component: PlayerDialogueComponent) -> void:
	var dialogue_box: DialogueBox = dialogue_box_prefab.instantiate()
	dialogue_box.dialogue_lines = dialogue_lines.duplicate()
	dialogue_box.finished.connect(func():
		player_component.finished_dialogue.call_deferred()
	)
	if bridge:
		dialogue_box.next.connect(_progress_quest.bind(QuestLine.ProgressMethod.NextButton))
	dialogue_container.add_child(dialogue_box)

	current_dialogue_box = dialogue_box

func _progress_quest(trigger_type: QuestLine.ProgressMethod) -> void:
	InGameQuestsBridge.progress_quest(trigger_type)
