extends HittableController
class_name SeekingHittableController
## Controls seeking behavior for "seeking" hittable objects

enum Targets {
	None,
	Switches,
	Enemies
}

@export var seeks_onto: Targets = Targets.None

var _current_scene: Node
var _seek_target: Node2D

const SWITCH_DISTANCE_TILL_STOP_SQUARED := 25.0

static var _seek_classes: Dictionary = {
	Targets.Switches: Switch,
	Targets.Enemies: Enemy
}

func _ready() -> void:
	if not _current_scene:
		_current_scene = get_tree().current_scene

func on_hit(p_attack_sign: int = 1) -> void:
	if seeks_onto != Targets.None:
		_seek_target = _get_closest_target_of_type(_get_target_type())
		if "use_gravity" in target:
			target.use_gravity = false
	super.on_hit(p_attack_sign)

func change_target(type: Targets) -> void:
	seeks_onto = type

func on_hit_target() -> void:
	if seeks_onto != Targets.None:
		stop()

func _get_velocity() -> Vector2:
	if _seek_target:
			return target.global_position.direction_to(_seek_target.global_position) * speed
	return super._get_velocity()

func _get_target_type():
	return _seek_classes[seeks_onto]

func _get_closest_target_of_type(type) -> Node2D:
	var targets := BabyGodotUtils.get_all_children_of_type(_current_scene, type)
	var minimum_dist_squared: float = INF
	var closest_target: Node2D = null
	for node in targets:
		if node is Node2D:
			var dist := target.global_position.distance_squared_to(node.global_position)
			if dist < minimum_dist_squared:
				minimum_dist_squared = dist
				closest_target = node
	return closest_target

func _process(_delta: float) -> void:
	if _is_active:
		if _seek_target:
			if seeks_onto == Targets.Switches and target.global_position.distance_squared_to(_seek_target.global_position) <= SWITCH_DISTANCE_TILL_STOP_SQUARED:
				stop()
			elif seeks_onto == Targets.Enemies and _seek_target.defeated:
				stop()
	super(_delta)
