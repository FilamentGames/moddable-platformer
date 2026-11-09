extends RefCounted
class_name Set
## Represents a set that can't contain duplicate elements.

var _elements: Array = []

## Returns true if the Set contains the given object
func has(value: Variant) -> bool:
	return _elements.has(value)

## Adds a new object to the Set, if it doesn't already have it.
func add(value: Variant) -> void:
	if not has(value):
		_elements.push_back(value)

## Removes the given value from the Set. Does nothing if the value doesn't exist.
func remove(value: Variant) -> void:
	_elements.erase(value)

## Returns the size of the Set
func size() -> int:
	return _elements.size()

## Returns a copy of the Set's values
func values() -> Array:
	return _elements.duplicate()