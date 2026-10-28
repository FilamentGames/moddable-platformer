extends GutTest
class_name BabyGodotTest
## Subclass of `GutTest` with shared helper methods

## Default tolerance for `assert_almost_eq`
const EPSILON = 0.00001

## Creates a new autofreed `CallableSpy`. Shortcut for nicer type inferenced code.
func create_spy() -> CallableSpy:
	return autofree(CallableSpy.new())

## Helper function that runs `assert_almost_eq` on both components of a Vector2
func assert_vector2_almost_eq(vec1: Vector2, vec2: Vector2, delta: float = EPSILON, text: String = "") -> void:
	assert_almost_eq(vec1.x, vec2.x, delta, text)
	assert_almost_eq(vec1.y, vec2.y, delta, text)