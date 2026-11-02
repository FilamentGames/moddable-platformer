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
	assert_eq(dict["animator"]["$"], "../Animator", "Node reference is serialized as path")

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

func test_it_can_apply_a_deserialization_in_place_with_no_new_instantiation():
	var coin: Coin = autofree(load("res://components/coin/coin.tscn").instantiate())
	coin.position.x = 67
	coin.position.y = 1337

	var record := serializer.serialize(coin)

	coin.position.x = -0xdeadbeef
	coin.position.y = -0xdeadbeef

	serializer.deserialize_in_place(coin, record)

	assert_eq(coin.position.x, 67.0)
	assert_eq(coin.position.y, 1337.0)

func test_it_can_deserialize_a_tilemaplayer():
	var level: Node2D = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	var tilemap: TileMapLayer = level.get_node("TileMapLayer")

	assert_not_null(tilemap)

	var dict := JSON.parse_string(JSON.stringify(serializer.serialize(tilemap)))


	var new_tilemap: TileMapLayer = autofree(serializer.deserialize(dict))

	assert_eq(tilemap.tile_map_data, new_tilemap.tile_map_data, "Tile Map Data is preserved")
	assert_eq(tilemap.tile_set, new_tilemap.tile_set)

func test_it_can_serialize_the_bridge_platform_correctly():
	var bridge: Node = autofree(load("res://components/platform/platform_level0_bridge.tscn").instantiate())
	bridge._should_initialize_reset_on_unpause = false
	var editable_object_indicator: EditableObjectIndicator = autofree(load("res://components/babygodot/editable_object_indicator/editable_object_indicator.tscn").instantiate())
	add_child(bridge)

	bridge.add_child(editable_object_indicator)

	var dict = serializer.serialize(bridge)

	assert_eq(dict["$children"].size(), 1)
	assert_eq(dict.keys().size(), 3)

func test_it_can_serialize_and_deserialize_an_array_of_nodes():
	var scene: Node = autofree(Node.new())
	var editable_node_list: EditableNodeList = autofree(EditableNodeList.new())
	editable_node_list.name = "EditableNodeList"
	var obj_a: Node2D = autofree(Node2D.new())
	obj_a.name = "Potato"
	var obj_b: Node2D = autofree(Node2D.new())
	obj_b.name = "Tomato"
	editable_node_list.nodes = [obj_a, obj_b]
	scene.add_child(editable_node_list)
	scene.add_child(obj_a)
	scene.add_child(obj_b)

	var dict := serializer.serialize(editable_node_list)

	assert_true(dict.has("nodes"))
	assert_eq(dict["nodes"]["$"].size(), 2)
	assert_false(dict["nodes"]["$"][0] is Node)

	var new_list: EditableNodeList = autofree(serializer.deserialize(dict, scene))

	assert_eq(new_list.nodes.size(), 2)
	assert_eq(new_list.nodes[0], obj_a)
	assert_eq(new_list.nodes[1], obj_b)

func test_it_resets_other_properties_to_default_if_its_deserializing_in_place():
	var tilemap: TileMapLayer = autofree(TileMapLayer.new())

	var level: Node2D = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	var target_tilemap: TileMapLayer = level.get_node("TileMapLayer")
	tilemap.tile_set = target_tilemap.tile_set

	serializer.deserialize_in_place(target_tilemap, serializer.serialize(tilemap))

	assert_eq(target_tilemap.tile_map_data, tilemap.tile_map_data)