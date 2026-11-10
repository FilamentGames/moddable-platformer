extends BabyGodotTest

var checkpoint: CheckpointHelper
var editor_interface: FakeEditorInterface

func before_each():
	editor_interface = autofree(FakeEditorInterface.new())
	editor_interface.scene_root = autofree(Node2D.new())
	checkpoint = autofree(CheckpointHelper.new(editor_interface))
	checkpoint.undo_redo = autofree(FakeUndoRedo.new())

func after_each():
	await get_tree().process_frame
	editor_interface.scene_root.free()
	checkpoint.scene_delta._delete()

func test_can_restore_a_collected_coin():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var pristine_scene_copy = autofree(editor_interface.scene_root.duplicate())

	var collected_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	var transform := collected_coin.transform
	assert_not_null(collected_coin)

	checkpoint.register_node_deleted(collected_coin)
	editor_interface.scene_root.remove_child(collected_coin)
	collected_coin.free()

	checkpoint.set_editor_scene()

	assert_not_null(editor_interface.scene_root.find_child("Coin"))
	assert_eq(editor_interface.scene_root.find_child("Coin").transform, transform)

	for child in pristine_scene_copy.get_children():
		assert_not_null(UniqueSceneId.find_by_id(editor_interface.scene_root, UniqueSceneId.get_id(child)))
	
	for child in editor_interface.scene_root.get_children():
		child.free()

func test_can_reset_an_editable_objects_position():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var unmovable_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	var movable_enemy: Enemy = editor_interface.scene_root.find_child("Enemy")
	var initial_enemy_position: Vector2 = movable_enemy.position

	unmovable_coin.position.x = -1337
	unmovable_coin.position.y = -1337
	movable_enemy.position.x = -1337
	movable_enemy.position.y = -1337

	checkpoint.set_editor_scene()

	assert_eq(unmovable_coin.position, Vector2(-1337,-1337))
	assert_eq(movable_enemy.position, initial_enemy_position)

func test_can_reset_an_object_connected_to_an_editable_object():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var enemy: Enemy = editor_interface.scene_root.find_child("Enemy")
	# We're not calling `register_node_deleted` here since we're emulating a player deleting the node in the editor.
	var initial_enemy_position: Vector2 = enemy.position
	editor_interface.scene_root.remove_child(enemy)
	enemy.free()

	checkpoint.set_editor_scene()
	var new_enemy: Enemy = editor_interface.scene_root.find_child("Enemy")
	var yarnspark_condition: ObjectPropertyEqualityScrollCondition = editor_interface.scene_root.get_node("Yarnspark/ObjectPropertyEqualityScrollCondition")

	assert_not_null(yarnspark_condition)
	assert_eq(yarnspark_condition.target, new_enemy)

	assert_not_null(new_enemy)
	assert_eq(new_enemy.position, initial_enemy_position)

func test_can_reset_a_yarnspark_gate_transformation():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()
	
	var gate: CollectibleGate = editor_interface.scene_root.get_node("Gate")
	var open_gate: Node2D = autofree(gate.open_gate_prefab.instantiate())
	checkpoint.register_node_deleted(gate)
	gate.get_parent().add_child(open_gate)
	open_gate.position = gate.position
	gate.get_parent().remove_child(gate)
	gate.free()
	checkpoint.register_node_added(open_gate)

	checkpoint.set_editor_scene()
	var new_gate: CollectibleGate = editor_interface.scene_root.get_node("Gate")

	assert_not_null(new_gate)
	assert_null(open_gate.get_parent())

func test_it_can_undo_resetting_a_checkpoint():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	# Remove the coin
	var collected_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	checkpoint.register_node_deleted(collected_coin)
	editor_interface.scene_root.remove_child(collected_coin)
	collected_coin.free()

	# Move the enemy
	var movable_enemy: Enemy = editor_interface.scene_root.find_child("Enemy")
	movable_enemy.position.x = -1337
	movable_enemy.position.y = -1337

	# Open the gate
	var gate: CollectibleGate = editor_interface.scene_root.get_node("Gate")
	var open_gate: Node2D = autofree(gate.open_gate_prefab.instantiate())
	open_gate.name = "OpenGate"
	checkpoint.register_node_deleted(gate)
	gate.get_parent().add_child(open_gate)
	open_gate.position = gate.position
	gate.get_parent().remove_child(gate)
	gate.free()
	checkpoint.register_node_added(open_gate)

	checkpoint.set_editor_scene()
	checkpoint.undo_redo.undo()

	assert_null(editor_interface.scene_root.get_node_or_null("Coin"))
	assert_vector2_almost_eq(editor_interface.scene_root.find_child("Enemy").position, Vector2(-1337, -1337))
	assert_null(editor_interface.scene_root.get_node_or_null("Gate"))
	assert_not_null(editor_interface.scene_root.get_node("OpenGate"))

func test_it_doesnt_get_confused_with_more_parent_nodes():
	var super_parent: Node = autofree(Node.new())

	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())

	super_parent.add_child(editor_interface.scene_root)
	checkpoint.save_editor_scene_as_checkpoint()

	# Remove the coin
	var collected_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	checkpoint.register_node_deleted(collected_coin)
	editor_interface.scene_root.remove_child(collected_coin)
	collected_coin.free()

	checkpoint.set_editor_scene()

	assert_not_null(editor_interface.scene_root.get_node("Coin"))

func test_it_can_save_a_new_checkpoint():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	# Remove the coin
	var collected_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	checkpoint.register_node_deleted(collected_coin)
	editor_interface.scene_root.remove_child(collected_coin)
	collected_coin.free()

	checkpoint.save_editor_scene_as_checkpoint()
	checkpoint.set_editor_scene()

	assert_null(editor_interface.scene_root.get_node_or_null("Coin"))

func test_player_position_is_specifically_handled():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var player: Player = editor_interface.scene_root.get_node("Player")
	var initial_position = player.position
	player.position = Vector2(-1337, -1337)

	checkpoint.set_editor_scene()

	assert_vector2_almost_eq(initial_position, player.position)

func test_player_position_can_be_undone():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var player: Player = editor_interface.scene_root.get_node("Player")
	var initial_position = player.position
	player.position = Vector2(-1337, -1337)

	checkpoint.set_editor_scene()
	checkpoint.undo_redo.undo()

	assert_vector2_almost_eq(Vector2(-1337, -1337), player.position)

func test_can_hit_reset_multiple_times_and_it_does_nothing_after_first_reset():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()
	var children := editor_interface.scene_root.get_child_count()

	# Remove the coin
	var collected_coin: Node2D = editor_interface.scene_root.find_child("Coin")
	checkpoint.register_node_deleted(collected_coin)
	editor_interface.scene_root.remove_child(collected_coin)
	collected_coin.free()

	checkpoint.set_editor_scene()
	checkpoint.set_editor_scene()
	checkpoint.set_editor_scene()
	checkpoint.set_editor_scene()
	checkpoint.set_editor_scene()

	assert_eq(editor_interface.scene_root.get_child_count(), children)

func test_can_reset_a_collected_yarnspark():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	# Remove the coin
	var collected_yarnspark: Node2D = editor_interface.scene_root.get_node("Yarnspark")
	checkpoint.register_node_deleted(collected_yarnspark)
	editor_interface.scene_root.remove_child(collected_yarnspark)
	collected_yarnspark.free()

	checkpoint.set_editor_scene()

	assert_not_null(editor_interface.scene_root.get_node_or_null("Yarnspark"))
	assert_not_null(editor_interface.scene_root.get_node_or_null("Yarnspark/ObjectPropertyEqualityScrollCondition"))

func test_can_reset_a_switched_on_switch():
	editor_interface.scene_root = autofree(load("res://addons/quests/test/scenes/checkpoint_tests/checkpoint_level.tscn").instantiate())
	checkpoint.save_editor_scene_as_checkpoint()

	var switch: Switch = editor_interface.scene_root.get_node("Switch")
	switch.on = true
	checkpoint.register_node_modified(switch, "on", false, true)

	checkpoint.set_editor_scene()

	assert_false(switch.on, "Switch property is restored to before checkpoint")

	checkpoint.undo_redo.undo()

	assert_true(switch.on, "Switch property is restored to after checkpoint")
