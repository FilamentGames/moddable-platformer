extends GutTest

const scene_path := "res://addons/quests/test/scenes/unique_scene_id_test.tscn"
var packed_scene := preload("res://addons/quests/test/scenes/unique_scene_id_test.tscn")
var scene: Node2D

func before_each():
	scene = autofree(packed_scene.instantiate())

func test_it_can_get_the_id_of_the_scroll_object():
	var scroll = scene.find_child("Scroll")

	assert_eq(UniqueSceneId.get_id(scroll), scene_path + "%Scroll")

func test_it_can_get_the_id_of_a_coin_object():
	var coin = scene.find_child("Coin2")
	
	assert_eq(UniqueSceneId.get_id(coin), scene_path + "%Coins/Coin2")

func test_it_can_get_the_scroll_object_from_id():
	var scroll = scene.find_child("Scroll")

	assert_eq(UniqueSceneId.find_by_id(scene, UniqueSceneId.get_id(scroll)), scroll)

func test_it_returns_null_when_finding_an_object_with_no_delimeter():
	assert_null(UniqueSceneId.find_by_id(scene, "Scroll"))

func test_it_returns_null_if_finding_an_object_in_another_scene():
	assert_null(UniqueSceneId.find_by_id(scene, "res://not_a_real_file.tscn%Scroll"))

func test_it_returns_null_if_object_cannot_be_found():
	assert_null(UniqueSceneId.find_by_id(scene, scene_path + "%Potato"))

func test_it_can_get_all_coin_objects_in_scene():
	var coins := scene.find_children("Coin*")

	for child in coins:
		assert_eq(UniqueSceneId.find_by_id(scene, UniqueSceneId.get_id(child)), child)
