extends Node
class_name PlayerDialogueComponent
## Controls the player's interaction with dialogue zones.

## The dialogue box to spawn for forced/cutscene dialogue
@export var dialogue_box_prefab: PackedScene

@export_group("Internal Refs")
## A reference to the player object
@export var player: CharacterBody2D
## Where the dialogue box is instantiated for forced/cutscene dialogue
@export var dialogue_mount: Node2D

## The current list of dialogue zones the player exists in
var dialogue_zones: Array[Npc]

## A reference to the current dialogue box used for forced/"cutscene" dialogue
var current_cutscene_box: DialogueBox

## Whether the player's movement is locked or not
var movement_locked := false:
	get:
		return _movement_locked
	set(val):
		if player and "movement_locked" in player:
			# Set movement locked in the actual player if it's possible
			# This flexibility lets us keep the actual `Player` object out of tests
			player.movement_locked = val
		_movement_locked = val

var _movement_locked := false

func _process(_delta: float) -> void:
	if movement_locked:
		return
	if Input.is_action_just_pressed("player_action"):
		if dialogue_zones.size() > 0:
			movement_locked = true
			dialogue_zones.back().spawn_dialogue_box(self)

## This is called once the dialogue is finished
func finished_dialogue() -> void:
	movement_locked = false

func force_dialogue(lines: Array[String]) -> void:
	movement_locked = true
	var dialogue_box: DialogueBox = dialogue_box_prefab.instantiate()
	dialogue_box.dialogue_lines = lines.duplicate()
	dialogue_box.finished.connect(func():
		finished_dialogue.call_deferred()
	)
	dialogue_mount.add_child(dialogue_box)
	current_cutscene_box = dialogue_box
