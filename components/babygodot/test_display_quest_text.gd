extends Node2D

@export var label: Label

var bridge := InGameQuestsBridge.new()

func _ready():
	bridge.quest_text.connect(_update_quest_text)
	bridge.request_quest_text()

func _update_quest_text(text: String):
	label.text = text
