extends AbstractTriggerBehavior
class_name DemoEndBehavior
## Freezes the player and shows the end screen

## The end screen prefab
@export var end_screen: PackedScene

func run_trigger() -> void:
	var player: Player = BabyGodotUtils.get_first_child_of_type(get_tree().current_scene, Player)
	if not player:
		return
	player.control_locked = true
	var end_screen_instance: CanvasLayer = end_screen.instantiate()
	player.add_child(end_screen_instance)
