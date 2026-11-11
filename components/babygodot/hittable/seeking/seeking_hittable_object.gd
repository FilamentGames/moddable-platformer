extends HittableObject
class_name SeekingHittableObject

signal changed_seeking_target(target: SeekingHittableController.Targets)

@export var seeks_onto: SeekingHittableController.Targets = SeekingHittableController.Targets.None:
	set(value):
			_seeks_onto = value
			changed_seeking_target.emit(_seeks_onto)
	get:
		return _seeks_onto

var _seeks_onto: SeekingHittableController.Targets = SeekingHittableController.Targets.None

func _ready() -> void:
	changed_seeking_target.emit(_seeks_onto)
	super._ready()

	_reset_on_unpause.on_reset.connect(func():
		changed_seeking_target.emit(_seeks_onto)
	)
