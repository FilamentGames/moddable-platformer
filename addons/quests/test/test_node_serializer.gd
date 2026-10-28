extends BabyGodotTest

var serializer: NodeSerializer

func before_each():
	serializer = autofree(NodeSerializer.new())

func after_each():
	serializer.clear()

func test_it_can_serialize_and_deserialize_a_simple_prefab():
	var prefab: Node = autofree(load("res://addons/quests/test/scenes/serializer/test_prefab.tscn").instantiate())

	var dict = serializer.serialize(prefab)

	assert_eq(dict["$prefab"], "res://addons/quests/test/scenes/serializer/test_prefab.tscn")
	assert_false(dict.has("transform"), "Non 2D/3D node type should not serialize transform")

	var new_prefab: Node = autofree(serializer.deserialize(dict))

	assert_eq(new_prefab.scene_file_path, prefab.scene_file_path)
	assert_eq(new_prefab.name, prefab.name)

func test_it_can_serialize_transforms():
	var coin: Node2D = autofree(load("res://components/coin/coin.tscn").instantiate())

	coin.position = Vector2(10, 20)
	coin.rotation = 1
	coin.scale = Vector2(2, 3)
	coin.skew = 0.5

	var dict := serializer.serialize(coin)

	assert_true(dict.has("transform"), "Node2D should serialize transform")
	assert_false(dict.has("position"), "Only transform is serialized, not computed values")
	assert_false(dict.has("rotation"), "Only transform is serialized, not computed values")
	assert_false(dict.has("scale"), "Only transform is serialized, not computed values")
	assert_false(dict.has("skew"), "Only transform is serialized, not computed values")
	assert_eq(dict.keys().size(), 3, "Minimum number of props serialized: " + str(dict.keys()))

	var new_coin: Node2D = autofree(serializer.deserialize(dict))

	assert_vector2_almost_eq(new_coin.position, Vector2(10, 20))
	assert_almost_eq(new_coin.rotation, 1.0, EPSILON)
	assert_vector2_almost_eq(new_coin.scale, Vector2(2, 3))
	assert_almost_eq(new_coin.skew, 0.5, EPSILON)

func test_it_stores_object_props_that_are_different_from_prefab():
	var coin: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())

	coin.tint = Color.BLUE
	
	var dict := serializer.serialize(coin)

	assert_true(dict.has("tint"), "Serializer registers a modified property")
	assert_false(dict.has("animator"), "Serializer does not register an unchanged property")

	assert_eq(Color.BLUE, autofree(serializer.deserialize(dict)).tint, "Serializes/Deserializes color correctly")

func test_it_serializes_node_references_as_paths():
	var parent: Node = autofree(Node.new())
	var animator: AnimationPlayer = autofree(AnimationPlayer.new())
	animator.name = "Animator"
	parent.add_child(animator)

	var coin: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())
	parent.add_child(coin)
	coin.animator = animator

	var dict := serializer.serialize(coin)

	assert_true(dict.has("animator"))
	assert_eq(dict["animator"], "../Animator", "Node reference is serialized as path")

	var new_coin: Coin = autofree(serializer.deserialize(dict, parent))

	assert_eq(new_coin.animator, animator, "Node path is deserialized properly")

func test_it_caches_reference_prototypes_for_prefabs():
	var coin: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())

	var dict := serializer.serialize(coin)

	serializer._prototypes["res://components/coin/coin.tscn"].tint = Color.BLUE

	var dict2 := serializer.serialize(coin)

	assert_false(dict.has("tint"))
	assert_true(dict2.has("tint"))

func test_it_serializes_and_deserializes_children():
	var coin: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())
	var coin2: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())
	coin.add_child(coin2)
	coin2.name = "Potato"

	var dict := serializer.serialize(coin)

	assert_true(dict.has("$children"))

	var new_coin: Coin = autofree(serializer.deserialize(dict))

	assert_not_null(new_coin.get_node("Potato"))

var type_params = [
	['vector2', Vector2(1.0, 2.0)],
	['vector2i', Vector2i(1, 2)],
	['vector3', Vector3(1.0, 2.0, 3.0)],
	['vector3i', Vector3i(1, 2, 3)],
	['color', Color.PAPAYA_WHIP],
	['rect2', Rect2(1.0, 2.0, 3.0, 4.0)],
	['rect2i', Rect2i(1, 2, 3, 4)],
	['array', [1.0, 2.0, "abcd", Vector2(1.0, 2.0)]],
	['dictionary', {"potato": "tomato", "position": Vector2(1.0, 2.0)}],
	['scene', load("res://addons/quests/test/scenes/serializer/all_types_prefab.tscn")]
]
func test_it_serializes_ALL_the_types_in_JSON_friendly_format(params=use_parameters(type_params)):
	var node: Node = autofree(load("res://addons/quests/test/scenes/serializer/all_types_prefab.tscn").instantiate())

	node.set(params[0], params[1])

	var dict: Dictionary = JSON.parse_string(
		JSON.stringify(serializer.serialize(node))
	)

	var new_node = autofree(serializer.deserialize(dict))

	if params[1] is Array:
		for i in params[1].size():
			assert_eq(new_node.get(params[0])[i], params[1][i], str(i + 1) + "th array element serialized/deserialized correctly")
	elif params[1] is Dictionary:
		for i in params[1].keys():
			assert_eq(new_node.get(params[0])[i], params[1][i], "Key " + i + " in Dictionary serialized/deserialized correctly")
	elif params[1] is PackedScene:
		var scene: PackedScene = params[1]
		assert_eq(scene.resource_path, new_node.get(params[0]).resource_path, "Scenes are equal")
	else:
		assert_eq(new_node.get(params[0]), params[1], "Type " + params[0] + " serialized/deserialized correctly.")