@tool
extends Node2D
class_name EditableObjectIndicator
## Marks editable objects in the editor

var radius: float = 5.0

var offset := Vector2(0, 0)

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
	var parent := get_parent()
	if not "position" in parent:
		var parent_2d: Node2D = parent.get_parent()
		while not "position" in parent_2d:
			parent_2d = parent_2d.get_parent()
		offset = parent_2d.global_position
	var collisionShape: CollisionShape2D = BabyGodotUtils.get_first_child_of_type(parent, CollisionShape2D)
	if collisionShape:
		var aabb := collisionShape.shape.get_rect()
		radius = max(aabb.size.x * collisionShape.scale.x / 2, aabb.size.y * collisionShape.scale.y / 2)
	

func _draw() -> void:
	var width := ceilf(sqrt(radius))
	draw_circle(position + offset, radius + width, Color.GREEN, false, width)
