extends Node
class_name ScrollContinuity

var bridge: InGameQuestsBridge

func _ready() -> void:
	bridge = InGameQuestsBridge.new()

func _on_collect():
	bridge.collect_scroll(UniqueSceneId.get_id(get_parent()))
