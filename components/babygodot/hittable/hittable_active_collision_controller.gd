extends Node

@export var area: Area2D

func set_collision_active(active: bool) -> void:
	area.set_collision_layer_value(7, active)
