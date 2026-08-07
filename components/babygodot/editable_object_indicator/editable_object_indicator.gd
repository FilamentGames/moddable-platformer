@tool
extends Node2D
class_name EditableObjectIndicator
## Marks editable objects in the editor

## The margin to add to rectangle's size.
@export var margins: Vector2 = Vector2(0, 0)

@export_group("Internal Refs")

## The root of the edit icon.
@export var edit_icon: Node2D

## The sprite for the pencil icon.
@export var pencil_sprite: Sprite2D

## The sprite for the arrow icon.
@export var arrow_rotation_pivot: Node2D

## The box that's drawn around the object.
@export var box: Control

## The offset from the standard position of the object.
var offset := Vector2(0, 0)

## The size of the rectangle to draw.
var rect_size: Vector2 = Vector2(0, 0)

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
	var parent := get_parent()
	if not "position" in parent:
		var parent_2d: Node2D = parent.get_parent()
		while not "position" in parent_2d:
			parent_2d = parent_2d.get_parent()
		offset = parent_2d.global_position
	position += offset
	_get_rect_size()

func _process(_delta: float) -> void:
	if get_parent() is CollectibleCondition:
		global_rotation = PI / 2
	if pencil_sprite:
		pencil_sprite.global_rotation = 0
	if arrow_rotation_pivot:
		arrow_rotation_pivot.global_rotation = edit_icon.global_rotation
	global_scale = Vector2(1, 1)
	_get_rect_size()

func _get_rect_size() -> void:
	var collisionShape: CollisionShape2D = BabyGodotUtils.get_first_child_of_type(get_parent(), CollisionShape2D)
	if collisionShape:
		var aabb := collisionShape.shape.get_rect()
		rect_size = aabb.size * collisionShape.global_scale
		box.size = rect_size + margins * 2
		box.position = -box.size / 2
		edit_icon.position = Vector2(0, -rect_size.y / 2 - margins.y / 2)
