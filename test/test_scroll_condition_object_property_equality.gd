extends GutTest

var condition: ObjectPropertyEqualityScrollCondition
var obj: MockObject

class MockObject extends Node:
	var property_int: int = 25
	var property_string: String = "Lorem"
	var property_float: float = 2.718
	var property_bool: bool = true
	var property_vector2: Vector2 = Vector2(1, 2)
	var property_color: Color = Color.BLUE

func before_each():
	condition = autofree(ObjectPropertyEqualityScrollCondition.new())
	obj = autofree(MockObject.new())
	condition.target = obj

var test_params = [
	["property_int", "25", "24"],
	["property_string", "Lorem", "Ipsum"],
	["property_float", "2.718", "2.719"],
	["property_bool", "true", "false"],
	["property_vector2", "Vector2(1, 2)", "Vector2(3, 4)"],
	["property_color", "Color(0, 0, 1, 1)", "Color(1, 0, 0, 1)"],
]

func test_it_can_compare_values(params = use_parameters(test_params)):
	condition.property_name = params[0]
	condition.value = params[1]

	assert_true(condition.is_condition_met())

	condition.value = params[2]

	assert_false(condition.is_condition_met())

func test_it_can_display_user_friendly_property_name_in_label_text():
	condition.property_name = "property_int"

	assert_string_contains(condition.get_label_text(), "Property Int")

	condition.property_name = "name"

	assert_string_contains(condition.get_label_text(), "Name")

func test_it_says_enabled_or_disabled_in_label_text_for_bool_values():
	condition.property_name = "property_bool"
	condition.value = "true"

	assert_string_contains(condition.get_label_text(), "must be enabled.")

	condition.value = "false"

	assert_string_contains(condition.get_label_text(), "must be disabled.")
