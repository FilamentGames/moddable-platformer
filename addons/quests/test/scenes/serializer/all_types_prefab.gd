extends Node2D

@export var vector2: Vector2 = Vector2.ZERO
@export var vector2i: Vector2i = Vector2i.ZERO
@export var vector3: Vector3 = Vector3.ZERO
@export var vector3i: Vector3i = Vector3i.ZERO
@export var color: Color = Color.WHITE
@export var rect2: Rect2 = Rect2(0, 0, 0, 0)
@export var rect2i: Rect2i = Rect2i(0, 0, 0, 0)
@export var array: Array = []
@export var dictionary: Dictionary = {}
@export var scene: PackedScene = load("res://addons/quests/test/scenes/serializer/test_prefab.tscn")
