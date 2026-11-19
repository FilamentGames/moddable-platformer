@tool
class_name AnimatablePlatform
extends AnimatableBody2D
## A version of Moddable Platformer's platform script that extends AnimatableBody2D so that it can be controlled by a PathFollow2D node.

const FRAME_COORDS_ONE_WAY_LEFT := Vector2i(5, 0)
const FRAME_COORDS_ONE_WAY_MIDDLE := Vector2i(6, 0)
const FRAME_COORDS_ONE_WAY_RIGHT := Vector2i(7, 0)
const FRAME_COORDS_ONE_WAY_SINGLE := Vector2i(8, 0)
const FRAME_COORDS_SOLID := Vector2i(10, 1)

## How many tiles wide is the platform?
@export_range(1, 20, 1, "suffix:tiles") var width: int = 3:
	set = _set_width

## Can you jump through the bottom of the platform?
@export var one_way: bool = false:
	set = _set_one_way

@export_group("Tileset")
## Which tileset should be used to draw the platform?
@export var tile_set: TileSet = load("res://spaces/tileset-threadbare.tres"):
	set = _set_tile_set

## Which index of the tileset should be used to draw the platform?
@export var tile_set_index: int = 0:
	set(value):
		tile_set_index = value
		_on_platform_sprite_update()

## Whether to use the left and right frames for the platform.
## If [code]false[/code], the middle frame will be used for all parts of the platform.
@export var use_left_and_right_frames: bool = true:
	set(value):
		use_left_and_right_frames = value
		_on_platform_sprite_update()

## The tile coordinates for the left part of the platform.
@export var tile_set_left_frame: Vector2i = FRAME_COORDS_ONE_WAY_LEFT:
	set(value):
		tile_set_left_frame = value
		_on_platform_sprite_update()

## The tile coordinates for the middle part of the platform.
@export var tile_set_middle_frame: Vector2i = FRAME_COORDS_ONE_WAY_MIDDLE:
	set(value):
		tile_set_middle_frame = value
		_on_platform_sprite_update()

## The tile coordinates for the right part of the platform.
@export var tile_set_right_frame: Vector2i = FRAME_COORDS_ONE_WAY_RIGHT:
	set(value):
		tile_set_right_frame = value
		_on_platform_sprite_update()

## How much to scale the collision shape vertically, useful for half-height platforms.
@export_range(0.0, 1.0, 0.05, "suffix:x") var collision_shape_y_scale: float = 1.0:
	set(value):
		collision_shape_y_scale = value
		_on_platform_sprite_update()

@onready var _sprites := %Sprites
@onready var _collision_shape: CollisionShape2D = %CollisionShape2D

func _set_tile_set(new_tile_set):
	if new_tile_set:
		tile_set = new_tile_set
	_on_platform_sprite_update()

func _set_width(new_width):
	width = new_width
	_on_platform_sprite_update()

func _set_one_way(new_one_way):
	one_way = new_one_way

	_on_platform_sprite_update()

func _on_platform_sprite_update() -> void:
	update_configuration_warnings()
	if is_node_ready():
		_recreate_sprites()


func _recreate_sprites():
	for c in _sprites.get_children():
		c.queue_free()

	if not tile_set.has_source(tile_set_index):
		return

	var tile_width := tile_set.tile_size.x
	var sprite: Texture2D = tile_set.get_source(tile_set_index).texture

	_collision_shape.one_way_collision = one_way
	_collision_shape.position.y = tile_width * (1.0 - collision_shape_y_scale) / -2.0
	_collision_shape.shape.set_size(Vector2(width * tile_width, tile_width * collision_shape_y_scale))

	var center: float = (width - 1) * tile_width / 2.0

	for i in range(0, width):
		var new_sprite := Sprite2D.new()
		new_sprite.texture = sprite
		new_sprite.hframes = 12
		new_sprite.vframes = 3
		if use_left_and_right_frames:
			if i == 0:
				if width == 1:
					new_sprite.frame_coords = tile_set_middle_frame
				else:
					new_sprite.frame_coords = tile_set_left_frame
			elif i == width - 1:
				new_sprite.frame_coords = tile_set_right_frame
			else:
				new_sprite.frame_coords = tile_set_middle_frame
		else:
			new_sprite.frame_coords = tile_set_middle_frame
		new_sprite.position = Vector2(i * tile_width - center, 0)
		_sprites.add_child(new_sprite)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if not tile_set.has_source(tile_set_index):
		warnings.append("TileSet has no atlas source 0.")
	else:
		var source := tile_set.get_source(tile_set_index)

		var expected_coords: Array[Vector2i]
		if use_left_and_right_frames:
			expected_coords = [
				tile_set_left_frame,
				tile_set_middle_frame,
				tile_set_right_frame,
			]
		else:
			expected_coords = [tile_set_middle_frame]

		for coords in expected_coords:
			if not source.has_tile(coords):
				warnings.append("TileSet atlas " + str(tile_set_index) + " has no tile at " + str(coords))

	return warnings

func _ready():
	_recreate_sprites()
