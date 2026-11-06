extends RefCounted
class_name FakeUndoRedo

var actions: Array[String] = []
var do_methods: Array[Callable] = []
var undo_methods: Array[Callable] = []

func create_action(action: String) -> void:
	actions.append(action)

func add_do_method(target: Object, method: StringName, ...args: Array) -> void:
	do_methods.append(Callable(target, method).bindv(args))

func add_undo_method(target: Object, method: StringName, ...args: Array) -> void:
	undo_methods.append(Callable(target, method).bindv(args))

func commit_action(execute: bool = true) -> void:
	if execute:
		for method in do_methods:
			method.call()

## Simulates the undo operation
func undo() -> void:
	for method in undo_methods:
		method.call()