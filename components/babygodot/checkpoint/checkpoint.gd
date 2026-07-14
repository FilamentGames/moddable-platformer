extends Node2D
class_name Checkpoint
## A "knit witch" character that appears and saves the player's current level state

## The scene to instantiate when the checkpoint is triggered to represent the knit witch the player can talk to.
@export var npc_prefab: PackedScene

## An object that represents where the player is placed when the checkpoint is captured.
@export var player_position_marker: Node2D

## A sprite that lets us visualize where the knit witch will spawn
@export var placeholder_sprite: AnimatedSprite2D

## Emitted when the checkpoint is triggered.
signal save_checkpoint()

func _ready() -> void:
	if placeholder_sprite:
		placeholder_sprite.visible = false

## Called when the player enters the collision area
func player_entered() -> void:
	queue_free()
	if not npc_prefab:
		return
	save_checkpoint.emit()
	_spawn_npc()

func _spawn_npc() -> void:
	var npc: Node2D = npc_prefab.instantiate()
	get_parent().add_child(npc)
	npc.position = position

func send_checkpoint_message() -> void:
	InGameQuestsBridge.activate_level_checkpoint(UniqueSceneId.get_id(self))
