extends BabyGodotTest

var checkpoint: CheckpointHelper
var editor_interface: FakeEditorInterface

class FakeEditorInterface:
	var scene_root: Node

	var edited_nodes: Array[Node] = []
	var saved_scene_calls: int = 0

	func get_edited_scene_root() -> Node:
		return scene_root
	
	func edit_node(node: Node) -> void:
		edited_nodes.append(node)
	
	func save_scene() -> void:
		saved_scene_calls += 1

class FakeUndoRedo:
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

func before_each():
	editor_interface = autofree(FakeEditorInterface.new())
	editor_interface.scene_root = autofree(Node2D.new())
	checkpoint = autofree(CheckpointHelper.new(editor_interface))
	checkpoint.undo_redo = autofree(FakeUndoRedo.new())

func after_each():
	editor_interface.scene_root.free()
	for root in checkpoint._duplicated_roots:
		root.free()
	checkpoint._duplicated_roots.clear()

func test_save_editor_scene_as_checkpoint():
	editor_interface.scene_root.name = "Potato"
	checkpoint.save_editor_scene_as_checkpoint()

	assert_not_null(checkpoint.saved_checkpoint_scene)
	assert_eq(autofree(checkpoint.saved_checkpoint_scene.instantiate()).name, "Potato")

func test_can_save_and_load_checkpoint():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_test.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var grabbed_coin = editor_interface.scene_root.find_child("Platform")
	assert_not_null(grabbed_coin)
	editor_interface.scene_root.remove_child(grabbed_coin)
	grabbed_coin.free()

	assert_eq(editor_interface.scene_root.get_child_count(), 2)

	checkpoint.set_editor_scene()

	assert_eq(editor_interface.scene_root.get_child_count(), 3)
	assert_not_null(editor_interface.scene_root.find_child("Platform"))

func test_can_undo_restoring_a_checkpoint():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_test.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var grabbed_coin = editor_interface.scene_root.find_child("Platform")
	assert_not_null(grabbed_coin)
	editor_interface.scene_root.remove_child(grabbed_coin)
	grabbed_coin.free()

	assert_eq(editor_interface.scene_root.get_child_count(), 2)
	assert_null(editor_interface.scene_root.find_child("Platform"))

	checkpoint.set_editor_scene()
	checkpoint.undo_redo.undo()

	assert_eq(editor_interface.scene_root.get_child_count(), 2)
	assert_null(editor_interface.scene_root.find_child("Platform"))