@tool
extends Control

## The label that shows the number of coins collected
@export var coin_count_label: Label

var internal_coin_count: int = 0

var bridge: InGameQuestsBridge

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_coins_label(GlobalQuests.quests.scrolls_collected.size())
		return
	bridge = InGameQuestsBridge.new()
	bridge.global_coins.connect(_update_coins_label)
	bridge.get_global_coins()
	Global.coin_collected.connect(_increment_coins_label)

func _update_coins_label(quantity: int) -> void:
	internal_coin_count = quantity
	coin_count_label.text = str(quantity)

func _increment_coins_label() -> void:
	_update_coins_label(internal_coin_count + 1)
