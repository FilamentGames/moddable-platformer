extends BabyGodotTest

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

func test_it_adds_editable_object_indicator_to_nodes_in_editable_node_list():
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

	assert_not_null(clone_copy.get_node_or_null("Node2D").get_node_or_null("EditableObjectIndicator"))

	clone_copy.free()

func test_it_adds_player_to_editable_nodes_if_add_player_to_editable_nodes_is_true():
	MasterCopyIndicator.add_player_to_editable_nodes = true

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
	var player: Player = autofree(Player.new())
	player.name = "Player"
	scene.add_child(player)
	player.owner = scene

	var packed_scene: PackedScene = autofree(PackedScene.new())
	packed_scene.pack(scene)
	var clone_copy: Node = autofree(MasterCopyIndicator._lock_uneditable_nodes(packed_scene).instantiate())

	assert_not_null(clone_copy.get_node_or_null("Player"))

	clone_copy.free()

func test_it_scans_the_level_for_watchable_nodes():
	var scene: PackedScene = load("res://addons/quests_devtools/test/scenes/test_checkpoint_data_helper_scene.tscn")

	var processed_scene: Node2D = autofree(MasterCopyIndicator._get_clone_copy_scene(scene).instantiate())
	var checkpoint_data: CheckpointDataHelper = processed_scene.get_node_or_null("CheckpointDataHelper")


	assert_not_null(checkpoint_data)

	var bare_nodes_list = checkpoint_data.watched_nodes.map(func(entry): return entry.node)
	var i = checkpoint_data.watched_nodes.find_custom(func(entry):
		return entry.node == ^"Yarnspark/ObjectPropertyEqualityScrollCondition"
	)
	var condition_entry = checkpoint_data.watched_nodes[i]

	## Gets nodes from the editable nodes list
	assert_array_contains(bare_nodes_list, ^"Coin")
	assert_array_contains(bare_nodes_list, ^"Enemy")

	## Gets nodes that have any connections to editable nodes
	assert_array_contains(bare_nodes_list, ^"Yarnspark/ObjectPropertyEqualityScrollCondition")
	assert_array_contains(condition_entry.dependencies, "Enemy")
	assert_array_contains(condition_entry.dependencies, ^"Yarnspark")
	assert_eq(condition_entry.dependencies.size(), 2, "Dependencies list is correct size")

	## Gets nodes in any future editable object list changes
	assert_array_contains(bare_nodes_list, ^"Coin3")

	## Gets nodes that have any connections to FUTURE editable nodes
	i = checkpoint_data.watched_nodes.find_custom(func(entry):
		return entry.node == ^"FutureCondition"
	)
	var future_condition_entry = checkpoint_data.watched_nodes[i]
	assert_array_contains(bare_nodes_list, ^"FutureCondition")
	assert_array_contains(future_condition_entry.dependencies, "Coin3")
	assert_eq(future_condition_entry.dependencies.size(), 1, "Dependencies list is correct size")

	## Adds the editable nodes list AND makes its dependencies
	i = checkpoint_data.watched_nodes.find_custom(func(entry):
		return entry.node == ^"EditableNodeList"
	)
	var editable_nodes_list = checkpoint_data.watched_nodes[i]
	assert_array_contains(bare_nodes_list, ^"EditableNodeList")
	assert_array_contains(editable_nodes_list.dependencies, "Coin")
	assert_array_contains(editable_nodes_list.dependencies, "Enemy")
	assert_array_contains(editable_nodes_list.dependencies, "Coin3")
	assert_eq(editable_nodes_list.dependencies.size(), 3)

	## Edge-case support for yarnsparks, that are collectible in-engine but may have a child that's watched and so they need to be constructed properly.
	i = checkpoint_data.watched_nodes.find_custom(func(entry):
		return entry.node == ^"Yarnspark"
	)
	var yarnspark = checkpoint_data.watched_nodes[i]
	assert_array_contains(bare_nodes_list, ^"Yarnspark")

	assert_eq(checkpoint_data.watched_nodes.size(), 7, "Watched object list is correct size")	