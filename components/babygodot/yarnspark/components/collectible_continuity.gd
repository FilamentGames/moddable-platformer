extends Node
class_name ScrollContinuity

@export var collectible: Collectible

var bridge: InGameQuestsBridge

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	bridge = InGameQuestsBridge.new()

func _on_collect():
	bridge.collect_scroll(UniqueSceneId.get_id(collectible))
