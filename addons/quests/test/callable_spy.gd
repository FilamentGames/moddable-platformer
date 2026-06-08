extends Object
class_name CallableSpy
## Represents a basic "spy" for a callable, registering the number of times a callable has been called

## Stores the number of calls. In GDScript, variables/primitives cannot actually be updated in a closure but object properties can be modified. So we encode the number of calls in an array.
var _calls: Array[Array] = []

## Use this where you want to pass a callable
var callable: Callable

func _init() -> void:
	callable = func(...data: Array):
		_calls.append(data)

## Returns the number of times the callable has been called
func get_number_of_calls() -> int:
	return _calls.size()
