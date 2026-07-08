extends GutTest
## Tests for the PlayerDialogueComponent and Npc objects

class MockPlayer extends CharacterBody2D:
	var movement_locked := false

class NpcTesting extends Npc:
	var trigger_type_used: int = -1

	func _progress_quest(trigger_type: QuestLine.ProgressMethod) -> void:
		trigger_type_used = trigger_type

var player: MockPlayer
var player_dialogue: PlayerDialogueComponent
var npc: NpcTesting
var sender: GutInputSender = InputSender.new(Input)

func make_dialogue_box_stub_prefab() -> PackedScene:
	var dialogue: DialogueBox = autofree(DialogueBox.new())
	var label: Label = autofree(Label.new())
	var next_button: Button = autofree(Button.new())
	dialogue.add_child(label)
	dialogue.add_child(next_button)
	dialogue.label = label
	dialogue.next_button = next_button
	label.owner = dialogue
	next_button.owner = dialogue

	var scene := PackedScene.new()
	scene.pack(dialogue)
	return scene

func add_collision_shape_as_child(parent: Node) -> void:
	var collision_shape: CollisionShape2D = autofree(CollisionShape2D.new())
	collision_shape.shape = autofree(RectangleShape2D.new())
	parent.add_child(collision_shape)

func create_player_detector() -> void:
	npc.player_detector = autofree(Area2D.new())
	npc.player_detector.set_collision_mask_value(1, 1)
	add_collision_shape_as_child(npc.player_detector)
	npc.add_child(npc.player_detector)

func before_all():
	InGameQuestsBridge._enabled = false

func before_each():
	player = autofree(MockPlayer.new())
	player_dialogue = autofree(PlayerDialogueComponent.new())
	player.add_child(player_dialogue)
	player_dialogue.player = player
	player_dialogue.owner = player

	npc = autofree(NpcTesting.new())
	npc.dialogue_lines = ["Lorem", "Ipsum"]
	npc.dialogue_box_prefab = autofree(make_dialogue_box_stub_prefab())
	npc.dialogue_container = autofree(Node2D.new())
	
	add_collision_shape_as_child(player)
	player.set_collision_layer_value(1, 1)
	create_player_detector()

	add_child(npc)
	add_child(player)

func after_each():
	sender.release_all()
	sender.clear()

func test_it_does_nothing_if_no_dialogue_zones_interacted_with():
	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	assert_false(player_dialogue.movement_locked)
	assert_eq(npc.dialogue_container.get_children().size(), 0)

func test_it_does_nothing_if_player_exits_dialogue_zone():
	npc._player_entered(player)
	npc._player_exited(player)

	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	assert_false(player_dialogue.movement_locked)
	assert_eq(npc.dialogue_container.get_children().size(), 0)

func test_it_can_spawn_dialogue():
	npc._player_entered(player)
	
	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)
	sender.action_up("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	assert_true(player_dialogue.movement_locked)
	assert_gt(npc.dialogue_container.get_children().size(), 0)

func test_it_does_not_spawn_dialogue_when_dialogue_already_active():
	npc._player_entered(player)

	for _i in 5:
		sender.action_down("player_action").wait_frames(1)
		player_dialogue._process(1)
		await(sender.idle)
		sender.action_up("player_action").wait_frames(1)
		player_dialogue._process(1)
		await(sender.idle)
	
	assert_true(player_dialogue.movement_locked)
	assert_eq(npc.dialogue_container.get_children().size(), 1)

func test_it_unfreezes_player_once_dialogue_is_done():
	npc._player_entered(player)

	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)
	sender.action_up("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	npc.current_dialogue_box.finished.emit()
	npc.current_dialogue_box.queue_free()

	# Since the call is deferred, we have to wait a frame
	await(get_tree().process_frame)
	
	assert_false(player_dialogue.movement_locked)

func test_spawned_dialogue_box_does_not_affect_npc_dialogue_data():
	npc._player_entered(player)
	
	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)
	sender.action_up("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	npc.current_dialogue_box._on_next_button_click()
	npc.current_dialogue_box._on_next_button_click()

	assert_eq(npc.dialogue_lines.size(), 2)

func test_npc_can_get_the_current_quest_line():
	npc.free()

	npc = autofree(NpcTesting.new())
	npc.dialogue_lines = []
	npc.use_global_quest_dialogue = true
	npc.dialogue_box_prefab = autofree(make_dialogue_box_stub_prefab())
	npc.dialogue_container = autofree(Node2D.new())
	npc.bridge = autofree(InGameQuestsBridge.new(autofree(MockEditorGameMessagingService.new())))

	add_child(npc)
	npc.bridge.all_nextbutton_quest_text.emit(["Current Quest"] as Array[String])

	npc._player_entered(player)
	
	sender.action_down("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)
	sender.action_up("player_action").wait_frames(1)
	player_dialogue._process(1)
	await(sender.idle)

	assert_eq(npc.current_dialogue_box.dialogue_lines[0], "Current Quest")

	npc.current_dialogue_box.next.emit()
	assert_eq(npc.trigger_type_used, QuestLine.ProgressMethod.NextButton, "Npc uses NextButton instead of script trigger")