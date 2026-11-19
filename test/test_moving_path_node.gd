extends BabyGodotTest

var follower: MovingPathNode
var path: Path2D
var curve: Curve2D

func before_each():
	follower = autofree(MovingPathNode.new())
	path = autofree(Path2D.new())
	curve = autofree(Curve2D.new())
	path.curve = curve

func test_it_is_a_follower2d_node():
	curve.add_point(Vector2(1, 0))
	curve.add_point(Vector2(2, 0))
	add_child(path)
	path.add_child(follower)

	follower.progress_ratio = 0.5

	assert_vector2_almost_eq(follower.position, Vector2(1.5, 0))

func test_it_has_a_speed_in_which_it_moves_back_and_forth():
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 0))
	path.add_child(follower)

	follower.cycle_time = 10.0
	follower.pause_time = 0.0
	add_child(path)

	follower._process(5.0)

	assert_almost_eq(follower.progress_ratio, 0.5, EPSILON)

	follower._process(9.0)

	assert_almost_eq(follower.progress_ratio, 0.6, EPSILON)

func test_it_has_a_stopping_time_where_it_doesnt_move_at_endpoints():
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 0))
	path.add_child(follower)

	follower.cycle_time = 10.0
	follower.pause_time = 5.0
	add_child(path)

	follower._process(5.0)

	assert_almost_eq(follower.progress_ratio, 0.0, EPSILON)

	follower._process(5.0)

	assert_almost_eq(follower.progress_ratio, 0.5, EPSILON)

	follower._process(7.5)

	assert_almost_eq(follower.progress_ratio, 1.0, EPSILON)

	follower._process(7.5)

	assert_almost_eq(follower.progress_ratio, 0.5, EPSILON)

## Practically we don't need this functionality because this bug only manifests if you keep the game open for hundreds of years to see floating point choppiness but... why not.
func test_it_is_resilient_to_silly_floating_point_bugs():
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 0))
	path.add_child(follower)

	follower.cycle_time = 10.0
	follower.pause_time = 5.0
	add_child(path)
	follower._t = 9007199254740990 ## Max safe integer - 1

	follower._process(5.0)

	assert_almost_eq(follower.progress_ratio, 0.0, EPSILON)

	follower._process(5.0)

	assert_almost_eq(follower.progress_ratio, 0.5, EPSILON)

	follower._process(7.5)

	assert_almost_eq(follower.progress_ratio, 1.0, EPSILON)

	follower._process(7.5)

	assert_almost_eq(follower.progress_ratio, 0.5, EPSILON)


