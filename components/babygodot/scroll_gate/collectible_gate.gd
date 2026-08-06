@tool
extends Node2D
class_name CollectibleGate

@export var required_collectibles: int = 1

@export_group("Misc. Properties")

## The name of the collectible that is required to pass the gate. If we ever need to change the name, we can do so here without code changes.
@export var collectible_name: String = "Yarnspark"

## The amount of time to wait before retrying if the bridge behavior is not ready.
@export var bridge_retry_timeout: float = 1.0

## The prefab that is used to instantiate the open gate.
@export var open_gate_prefab: PackedScene

@export_group("Internal Refs")

## The lanterns that are part of the gate
@export var lanterns: Array[CollectibleGateLantern] = []

## The behavior that the gate will use to query the global game state.
@export var bridge_behavior: AbstractBridgeBehavior

## The nodes that are deleted after the gate is opened. Stuff like door collision, trigger area, etc.
@export var to_delete_on_open: Array[Node] = []

@export var info_indicator: InfoIndicator

@export var info_indicator_label: RichTextLabel

## Emitted when the player enters the trigger area and does not have enough collectibles.
signal not_enough_collectibles()

## Emitted when the gate opening process has started.
signal gate_opening()

## Emitted when the player has left the trigger area.
signal hide_info_message()

func _ready() -> void:
	if info_indicator_label:
		info_indicator_label.text = _get_info_indicator_text()
	if info_indicator:
		info_indicator._on_deactivate()

	if lanterns.size() > 1:
		for i in lanterns.size() - required_collectibles:
			lanterns[i].lit = true

func _get_info_indicator_text() -> String:
	return "Bring " + str(required_collectibles) + " " + _get_collectible_name()

func _get_collectible_name() -> String:
	if required_collectibles > 1:
		return collectible_name + "s"
	return collectible_name

func player_entered() -> void:
	if not bridge_behavior:
		return
	if not bridge_behavior.is_ready:
		await get_tree().create_timer(bridge_retry_timeout).timeout
		player_entered()
		return
	if bridge_behavior.current_collectible_count < required_collectibles:
		not_enough_collectibles.emit()
	else:
		bridge_behavior.mark_gate_opened(self)
		bridge_behavior.deplete_collectible()
		gate_opening.emit()

func player_exited() -> void:
	hide_info_message.emit()

func open() -> void:
	for node in to_delete_on_open:
		node.queue_free()
