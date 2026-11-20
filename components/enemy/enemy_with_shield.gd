extends Enemy
class_name EnemyWithShield

@onready var _shield_parent: Node2D = %ShieldParent

func defeat(attack_sign: int = 0) -> void:
	if direction != attack_sign:
		return
	super.defeat(attack_sign)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_shield_parent.scale.x = direction
	
