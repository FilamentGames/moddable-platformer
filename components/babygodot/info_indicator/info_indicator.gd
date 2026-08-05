@tool
extends Node2D
class_name InfoIndicator

@export_group("Internal Refs")

## The node that contains the indicator sprite
@export var indicator: Node2D

## The node that contains the info panel
@export var info_panel: Node2D

## The actual canvas layer that the info panel exists in
@export var info_panel_canvas_layer: CanvasLayer

## The animation player
@export var animation: AnimationPlayer

func _ready() -> void:
	info_panel_canvas_layer.offset = info_panel.global_position
	animation.play(&"idle")

func _on_activate() -> void:
	animation.play(&"info_appear")

func _on_deactivate() -> void:
	animation.play(&"info_disappear")
	await animation.animation_finished
	animation.play(&"idle")

func _disable() -> void:
	visible = false
