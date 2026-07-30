extends AbstractTriggerBehavior
class_name ScreenShakeTriggerBehavior

@export_group("Screen shake")
## The duration of the screen shake in seconds
@export_range(0.0, 5.0, 0.05, "suffix:s") var duration: float = 0.5
## The maximum distance the camera will shake in pixels
@export_range(0.0, 100.0, 1.0, "suffix:px") var strength: float = 12.0
## The frequency of the screen shake in Hz
@export_range(1.0, 60.0, 1.0, "suffix:Hz") var frequency: float = 20.0

@export_group("Falling objects")
## The prefab to create when the screen shake is triggered
@export var prefab: PackedScene
@export var prefab_min_count: int = 3
@export var prefab_max_count: int = 8

var _screen_shake: ScreenShake

func run_trigger() -> void:
	var camera := _get_camera()
	if camera:
		_screen_shake = ScreenShake.new(camera, duration, strength, frequency)
		_screen_shake.run()
		var prefab_count = randi_range(prefab_min_count, prefab_max_count)
		for i in prefab_count:
			var prefab_instance := prefab.instantiate()
			get_tree().current_scene.add_child(prefab_instance)


func _get_camera() -> Camera2D:
	var camera := get_viewport().get_camera_2d()
	if camera:
		return camera

	var player: Player = BabyGodotUtils.get_first_child_of_type(get_tree().current_scene, Player)
	if player:
		return BabyGodotUtils.get_first_child_of_type(player, Camera2D)
	return null
