extends GutTest

var service: MockEditorGameMessagingService

func before_each():
	service = autofree(MockEditorGameMessagingService.new())

func test_in_game_object_can_connect():
	var bridge = autofree(InGameQuestsBridge.new(service))
	var spy = autofree(CallableSpy.new())
	bridge.quest_text.connect(spy.callable)
	service._capture("reply_get_quest_text", [bridge.id, "Hello World"])
	
	assert_eq(spy.get_number_of_calls(), 1)

func test_in_game_objects_only_receive_messages_for_their_id():
	var bridge = autofree(InGameQuestsBridge.new(service))
	var spy = autofree(CallableSpy.new())
	bridge.quest_text.connect(spy.callable)
	service._capture("reply_get_quest_text", [-1337, "Hello World"])
	
	assert_eq(spy.get_number_of_calls(), 0)

func test_clears_objects_after_they_are_destroyed():
	var bridge := InGameQuestsBridge.new(service)
	var id := bridge.id
	bridge.free()

	assert_false(service._object_map.has(id), "EditorGameMessagingService clears unused references")

func test_can_dispatch_a_global_message():
	var bridge_1 = autofree(InGameQuestsBridge.new(service))
	var bridge_2 = autofree(InGameQuestsBridge.new(service))
	var spy_1 = autofree(CallableSpy.new())
	var spy_2 = autofree(CallableSpy.new())
	bridge_1.quest_text.connect(spy_1.callable)
	bridge_2.quest_text.connect(spy_2.callable)
	service._capture("text_updated", [-1, "New Text"])

	assert_eq(spy_1.get_number_of_calls(), 1)
	assert_eq(spy_2.get_number_of_calls(), 1)
