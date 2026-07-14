extends GutTest

var checkpoint: Checkpoint

func before_each() -> void:
	var mock_checkpoint_npc: Node2D = autofree(Node2D.new())
	mock_checkpoint_npc.name = "KnitWitch"
	var scene: PackedScene = autofree(PackedScene.new())
	scene.pack(mock_checkpoint_npc)
	checkpoint = autofree(Checkpoint.new())
	checkpoint.npc_prefab = scene
	add_child(checkpoint)

func after_each() -> void:
	var npc = get_node_or_null("KnitWitch")
	if npc:
		npc.free()

func test_fires_save_checkpoint_event_when_player_enters() -> void:
	var spy: CallableSpy = autofree(CallableSpy.new())
	checkpoint.save_checkpoint.connect(spy.callable)

	checkpoint.player_entered()

	assert_eq(spy.get_number_of_calls(), 1)
	assert_true(checkpoint.is_queued_for_deletion())
	assert_not_null(get_node_or_null("KnitWitch"))

func test_does_not_spawn_npc_if_npc_prefab_is_null() -> void:
	checkpoint.npc_prefab = null
	var spy: CallableSpy = autofree(CallableSpy.new())
	checkpoint.save_checkpoint.connect(spy.callable)

	checkpoint.player_entered()

	assert_eq(spy.get_number_of_calls(), 0)
	assert_true(checkpoint.is_queued_for_deletion())
	assert_null(get_node_or_null("KnitWitch"))