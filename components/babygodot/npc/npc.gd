extends Node2D
class_name Npc
## An NPC that can spawn dialogue if the player hits the "action" button next to them.

## The lines of dialogue this NPC says.
@export var dialogue_lines: Array[String]

@export_group("Internal Refs")
## The triggerable area for the NPC.
@export var player_detector: Area2D

## The node in which the dialogue box is appended as a child to.
@export var dialogue_container: Node2D

## The dialogue box prefab to instantiate
var dialogue_box_prefab: PackedScene = preload("res://components/babygodot/dialogue_box/dialogue_box.tscn")

## A reference to the last spawned dialogue box
var current_dialogue_box: DialogueBox

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
		var index: int = component.dialogue_zones.rfind(self)
		component.dialogue_zones.remove_at(index)
	)

## Spawns a dialogue box for this NPC's dialogue
func spawn_dialogue_box(player_component: PlayerDialogueComponent) -> void:
	var dialogue_box: DialogueBox = dialogue_box_prefab.instantiate()
	dialogue_box.dialogue_lines = dialogue_lines.duplicate()
	dialogue_box.finished.connect(func():
		player_component.finished_dialogue.call_deferred()
	)
	dialogue_container.add_child(dialogue_box)

	current_dialogue_box = dialogue_box
