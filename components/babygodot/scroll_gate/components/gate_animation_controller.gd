extends Node
class_name GateAnimationController

@export var gate: CollectibleGate

@export var animator: AnimationPlayer

var player: Player

func _ready() -> void:
	player = BabyGodotUtils.get_first_child_of_type(get_tree().current_scene, Player)
	if not player:
		printerr("GateAnimationController can't find player")

func shake_door() -> void:
	animator.play(&"not_enough_scrolls")

func begin_opening_gate() -> void:
	player.control_locked = true
	for lantern in gate.lanterns:
		if lantern.lit:
			continue
		lantern.lit = true
		await lantern.animator.animation_finished
	animator.play(&"open")
	await animator.animation_finished
	gate.open()
	player.control_locked = false
