extends Node
class_name PlayerDialogueComponent
## Controls the player's interaction with dialogue zones.

@export_group("Internal Refs")
## A reference to the player object
@export var player: CharacterBody2D

## The current list of dialogue zones the player exists in
var dialogue_zones: Array[Npc]

## Whether the player's movement is locked or not
var movement_locked: bool = false:
	get:
		return _movement_locked
	set(val):
		if player and "movement_locked" in player:
			# Set movement locked in the actual player if it's possible
			# This flexibility lets us keep the actual `Player` object out of tests
			player.movement_locked = val
		_movement_locked = val

var _movement_locked: bool = false

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
