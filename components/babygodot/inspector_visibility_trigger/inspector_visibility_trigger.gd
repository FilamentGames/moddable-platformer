extends Area2D

enum InspectorVisibilityStatus {
	HIDDEN, ## Hides the inspector dock
	VISIBLE ## Shows the inspector dock
}

## The state the inspector should be set to.
@export var set_inspector_to: InspectorVisibilityStatus

func _on_player_enter():
	InGameQuestsBridge.set_inspector_dock_visible(set_inspector_to == InspectorVisibilityStatus.VISIBLE)
	queue_free()
	
