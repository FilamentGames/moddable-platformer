extends Node2D
class_name CollectibleGate

@export var required_scrolls: int = 1

@export_group("Internal Refs")

@export var scroll_gate_behavior: ScrollGateBehavior

@export var info_indicator: InfoIndicator

@export var info_indicator_label: RichTextLabel

func _ready() -> void:
	if scroll_gate_behavior:
		scroll_gate_behavior.required_scrolls = required_scrolls
	if info_indicator_label:
		info_indicator_label.text = "Bring " + str(required_scrolls) + " Yarnspark"
		if required_scrolls > 1:
			info_indicator_label.text += "s"
		info_indicator_label.text += " (but actually they're still called scrolls)"
	if info_indicator:
		info_indicator._on_deactivate()
