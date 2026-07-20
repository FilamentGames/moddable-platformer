extends AbstractTriggerBehavior

@export var add_objects: Array[Node] = []

@export var remove_objects: Array[Node] = []

func run_trigger() -> void:
	InGameQuestsBridge.update_editable_objects(_to_id_strings(add_objects), _to_id_strings(remove_objects))

func _to_id_strings(objects: Array[Node]) -> Array[String]:
	return objects.map(func(object): return UniqueSceneId.get_id(object))
