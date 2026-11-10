extends BabyGodotTest

var hittable: HittableController
var target: CharacterBody2D

func before_each():
	target = autofree(CharacterBody2D.new())
	hittable = autofree(HittableController.new())
	hittable.target = target

func test_it_exists():
	assert_not_null(hittable)

func test_it_can_react_to_a_hit():
	assert_vector2_almost_eq(target.velocity, Vector2.ZERO)

	hittable.speed = 1
	hittable.on_hit()

	assert_eq(target.velocity.x, 1.0)
	assert_eq(target.velocity.y, 0.0)

func test_it_continues_applying_velocity_each_frame():
	hittable.speed = 1
	hittable.on_hit()

	target.velocity.x = 0

	hittable._process(1.0)

	assert_eq(target.velocity.x, 1.0)
	assert_eq(target.velocity.y, 0.0)

func test_it_can_be_triggered_to_stop():
	hittable.speed = 1
	hittable.on_hit()
	hittable.stop()

	hittable._process(1.0)

	assert_eq(target.velocity.x, 0.0)

func test_it_can_be_hit_in_the_other_direction():
	hittable.speed = 1
	hittable.on_hit(-1)

	assert_eq(target.velocity.x, -1.0)
	assert_eq(target.velocity.y, 0.0)

	hittable._process(1.0)

	assert_eq(target.velocity.x, -1.0)
	assert_eq(target.velocity.y, 0.0)