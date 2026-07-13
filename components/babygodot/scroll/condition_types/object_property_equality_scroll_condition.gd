@tool
extends ScrollCondition
class_name ObjectPropertyEqualityScrollCondition
## Checks if an arbitrary property of a node is equal to a specific value.

## The target object to check the property of.
@export var target: Node

## The name of the property to check; this will be evaluated dynamically on the object.
@export var property_name: StringName

## The value to compare the object's property value to.
@export var value: String

func _get_label_ending() -> String:
	var ending := "must be equal to [code]" + value + "[/code]."
	if value == "true" or value == "false":
		ending = "must be enabled." if value == "true" else "must be disabled."
	return ending

func get_label_text() -> String:
	return "The [code]" + _get_display_property_name() + "[/code] property of the [code]" + target.name + "[/code] node " + _get_label_ending()

func _get_display_property_name() -> String:
	var pieces := Array(property_name.split("_"))
	return pieces.map(func(piece: String): return piece.capitalize()).reduce(func(a: String, b: String): return a + " " + b, "")

func _evaluate_expression(expression: String, base_object: Node = null) -> Variant:
	var expr := Expression.new()
	expr.parse(expression)
	return expr.execute([], base_object)

func is_condition_met() -> bool:
	var received = _evaluate_expression(property_name, target)

	if received is String:
		return received == value

	var expected = _evaluate_expression(value)

	return received == expected
