extends BabyGodotTest

var _set: Set

func before_each():
	_set = Set.new()

func test_it_exists():
	assert_not_null(_set)

func test_it_can_check_for_existence():
	assert_false(_set.has("Potato"))

func test_it_can_add_to_the_set():
	_set.add("Potato")

	assert_true(_set.has("Potato"))

func test_it_only_has_one_unique_copy_of_values():
	assert_eq(_set.size(), 0)

	_set.add("Potato")

	assert_eq(_set.size(), 1)

	_set.add("Potato")

	assert_eq(_set.size(), 1)

func test_it_can_get_the_list_of_values():
	_set.add("Potato")
	_set.add("Tomato")

	assert_eq(_set.values(), ["Potato", "Tomato"])

func test_it_can_remove_from_the_set():
	_set.add("Potato")
	_set.remove("Potato")
	_set.remove("Tomato")

	assert_false(_set.has("Potato"))
	assert_eq(_set.size(), 0)