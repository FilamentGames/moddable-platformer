extends GutTest

var indicator: MasterCopyIndicator

func before_all():
	MasterLevelLock.skip_assert = true

func before_each():
	indicator = autofree(MasterCopyIndicator.new())
	indicator.master_copy_directory = "res://levels/master/"

func test_it_hides_itself_on_levels_outside_of_master_dir():
	indicator.scene_changed("res://potato.tscn")

	assert_false(indicator.visible)

func test_it_shows_itself_on_levels_in_master_dir():
	indicator.scene_changed("res://levels/master/level0.tscn")

	assert_true(indicator.visible)

func test_it_can_take_a_scene_and_create_master_clone_copies():
	var scene: Node = autofree(Node.new())
	var child1: Node2D = autofree(Node2D.new())
	child1.name = "Node2D"
	var child2: Control = autofree(Control.new())
	child2.name = "Control"
	scene.add_child(child1)
	child1.owner = scene
	scene.add_child(child2)
	child2.owner = scene

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)	
	var master_copy: Node = autofree(MasterCopyIndicator._add_master_level_lock_to_scene(packed_scene).instantiate())
	var clone_copy: Node = autofree(MasterCopyIndicator._remove_master_level_lock_from_scene(packed_scene).instantiate())

	assert_not_null(master_copy.get_node_or_null("MasterLevelLock"))
	assert_null(clone_copy.get_node_or_null("MasterLevelLock"))
	assert_not_null(master_copy.get_node_or_null("Node2D"))
	assert_not_null(master_copy.get_node_or_null("Control"))
	assert_not_null(clone_copy.get_node_or_null("Control"))
	assert_not_null(clone_copy.get_node_or_null("Control"))

	master_copy.free()
	clone_copy.free()

func test_it_removes_lock_from_clone_copy_and_doesnt_duplicate_lock_in_master():
	var scene: Node = autofree(Node.new())
	var child1: Node2D = autofree(Node2D.new())
	child1.name = "Node2D"
	var child2: Control = autofree(Control.new())
	child2.name = "Control"
	scene.add_child(child1)
	child1.owner = scene
	scene.add_child(child2)
	child2.owner = scene
	var lock: MasterLevelLock = autofree(MasterLevelLock.new())
	lock.name = "MasterLevelLock"
	scene.add_child(lock)
	lock.owner = scene

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)
	var master_copy: Node = autofree(MasterCopyIndicator._add_master_level_lock_to_scene(packed_scene).instantiate())
	var clone_copy: Node = autofree(MasterCopyIndicator._remove_master_level_lock_from_scene(packed_scene).instantiate())

	assert_not_null(master_copy.get_node_or_null("MasterLevelLock"))
	assert_null(clone_copy.get_node_or_null("MasterLevelLock"))
	assert_not_null(master_copy.get_node_or_null("Node2D"))
	assert_not_null(master_copy.get_node_or_null("Control"))
	assert_not_null(clone_copy.get_node_or_null("Control"))
	assert_not_null(clone_copy.get_node_or_null("Control"))

	master_copy.free()
	clone_copy.free()

func test_it_adds_editable_node_list_to_master_copy():
	var scene: Node = autofree(Node.new())

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)
	var master_copy: Node = autofree(MasterCopyIndicator._add_editable_node_list_to_scene(packed_scene).instantiate())
	var clone_copy: Node = autofree(MasterCopyIndicator._lock_uneditable_nodes(packed_scene).instantiate())

	assert_not_null(master_copy.get_node_or_null("EditableNodeList"))
	assert_null(clone_copy.get_node_or_null("EditableNodeList"), "No errors when EditableNodeList is absent")

	master_copy.free()
	clone_copy.free()

func test_it_sets_edit_lock_on_nodes_not_in_editable_node_list():
	var scene: Node = autofree(Node.new())
	var child1: Node2D = autofree(Node2D.new())
	child1.name = "Node2D"
	scene.add_child(child1)
	child1.owner = scene
	var editable_node_list: EditableNodeList = autofree(EditableNodeList.new())
	editable_node_list.name = "EditableNodeList"
	editable_node_list.nodes = [child1]
	scene.add_child(editable_node_list)
	editable_node_list.owner = scene

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)
	var clone_copy: Node = autofree(MasterCopyIndicator._lock_uneditable_nodes(packed_scene).instantiate())

	assert_true(clone_copy.get_node_or_null("EditableNodeList").has_meta("_edit_lock_"))
	assert_false(clone_copy.get_node_or_null("Node2D").has_meta("_edit_lock_"))

	clone_copy.free()

func test_it_doesnt_lock_anything_if_editable_node_list_is_empty():
	var scene: Node = autofree(Node.new())
	var child1: Node2D = autofree(Node2D.new())
	child1.name = "Node2D"
	scene.add_child(child1)
	child1.owner = scene
	var editable_node_list: EditableNodeList = autofree(EditableNodeList.new())
	editable_node_list.name = "EditableNodeList"
	editable_node_list.nodes = []
	scene.add_child(editable_node_list)
	editable_node_list.owner = scene

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)
	var clone_copy: Node = autofree(MasterCopyIndicator._lock_uneditable_nodes(packed_scene).instantiate())

	assert_false(clone_copy.get_node_or_null("EditableNodeList").has_meta("_edit_lock_"))
	assert_false(clone_copy.get_node_or_null("Node2D").has_meta("_edit_lock_"))

	clone_copy.free()