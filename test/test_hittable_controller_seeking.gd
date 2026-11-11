extends BabyGodotTest

var controller: SeekingHittableController
var target: CharacterBody2D
var switch: Switch

class MockEnemy extends Node2D:
	var defeated := false

func before_all():
	InGameQuestsBridge._enabled = false
	SeekingHittableController._seek_classes[SeekingHittableController.Targets.Enemies] = MockEnemy

func before_each():
	target = autofree(CharacterBody2D.new())
	controller = autofree(SeekingHittableController.new())
	switch = autofree(Switch.new())
	controller.target = target
	controller.speed = 1
	controller._current_scene = self
	add_child(controller)
	add_child(target)
	add_child(switch)
	controller.owner = self
	target.owner = self
	switch.owner = self
	target.position = Vector2(0, 0)
	switch.position = Vector2(100, 0)

func test_it_exists():
	assert_not_null(controller)

func test_it_can_move_towards_a_switch():
	controller.seeks_onto = SeekingHittableController.Targets.Switches
	controller.on_hit(1)

	assert_vector2_almost_eq(target.velocity, Vector2(1, 0))

	controller.stop()
	controller.on_hit(-1)

	assert_vector2_almost_eq(target.velocity, Vector2(1, 0))

	controller.stop()
	switch.position = Vector2(0, 5)
	controller.on_hit(-1)

	assert_vector2_almost_eq(target.velocity, Vector2(0, 1))

func test_it_targets_the_closest_switch():
	controller.seeks_onto = SeekingHittableController.Targets.Switches

	var switch2: Switch = autofree(Switch.new())
	add_child(switch2)
	switch2.owner = self
	switch2.position = Vector2(-99, 0)

	controller.on_hit(1)

	assert_vector2_almost_eq(target.velocity, Vector2(-1, 0))

func test_it_falls_back_to_default_behavior_on_target_none():
	controller.seeks_onto = SeekingHittableController.Targets.None

	controller.speed = 1
	controller.on_hit(-1)

	assert_eq(target.velocity.x, -1.0)
	assert_eq(target.velocity.y, 0.0)

	controller._process(1.0)

	assert_eq(target.velocity.x, -1.0)
	assert_eq(target.velocity.y, 0.0)

func test_it_can_also_track_an_enemy():
	controller.seeks_onto = SeekingHittableController.Targets.Enemies

	var enemy = autofree(MockEnemy.new())
	add_child(enemy)
	enemy.owner = self
	enemy.position = Vector2(0, 100)

	controller.on_hit(1)

	assert_vector2_almost_eq(target.velocity, Vector2(0, 1))

func test_it_stops_once_it_has_hit_the_middle_of_a_switch():
	controller.seeks_onto = SeekingHittableController.Targets.Switches

	controller.on_hit(1)
	controller._process(1)

	assert_true(controller._is_active)

	target.global_position = switch.global_position

	controller._process(1)
	
	assert_false(controller._is_active)

func test_it_stops_once_it_has_defeated_an_enemy():
	controller.seeks_onto = SeekingHittableController.Targets.Enemies

	var enemy = autofree(MockEnemy.new())
	add_child(enemy)
	enemy.owner = self
	enemy.position = Vector2(0, 100)

	controller.on_hit(1)
	controller._process(1)

	assert_true(controller._is_active)

	enemy.defeated = true

	controller._process(1)
	
	assert_false(controller._is_active)