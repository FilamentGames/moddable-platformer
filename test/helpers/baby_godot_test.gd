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

## Asserts that an array contains a specific value
func assert_array_contains(arr: Array, value: Variant, text: String = "") -> void:
	var msg = text if not text.is_empty() else "Expecting `" + str(arr) + "` to contain `" + str(value) + "`"
	assert_true(arr.has(value), msg)

func assert_array_does_not_contain(arr: Array, value: Variant, text: String = "") -> void:
	var msg = text if not text.is_empty() else "Expecting `" + str(arr) + "` not to contain `" + str(value) + "`"
	assert_false(arr.has(value), msg)
