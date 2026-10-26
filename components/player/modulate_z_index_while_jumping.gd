extends Node
class_name ModulateZIndexWhileJumping
## A component that modulates the z-index of the player while they are jumping so that they appear above foreground elements while jumping up and behind them while back on the ground.

@export var player: CharacterBody2D
@export var z_index_offset: int = 1

var base_z_index: int = 0

func _ready() -> void:
	base_z_index = player.z_index

func _process(_delta: float) -> void:
	if player.velocity.y < 0:
		player.z_index = base_z_index + z_index_offset
	else:	
		player.z_index = base_z_index
