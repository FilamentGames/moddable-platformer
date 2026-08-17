extends GutTest

class MockDialogueBox extends DialogueBox:
	var camera_rect: Rect2
	var bounding_rect: Rect2

	func get_camera_rect() -> Rect2:
		return camera_rect
	
	func get_bounding_rect() -> Rect2:
		return bounding_rect

var dialogue: MockDialogueBox

func before_each():
	dialogue = autofree(MockDialogueBox.new())
	dialogue.adjust_position_if_cut_off = true
	dialogue.dialogue_lines = ["Lorem"]
	dialogue.label = autofree(RichTextLabel.new())
	dialogue.camera_rect = Rect2(0, 0, 100, 100)
	dialogue.canvas_layer = autofree(CanvasLayer.new())

func test_it_does_nothing_if_on_screen():
	dialogue.bounding_rect = Rect2(25, 25, 25, 25)
	dialogue.position = Vector2(25, 25)
	add_child(dialogue)

	assert_eq(dialogue.position, Vector2(25, 25))

func test_it_nudges_the_dialogue_box_on_screen():
	dialogue.bounding_rect = Rect2(-25, -25, 25, 25)
	dialogue.position = Vector2(-25, -25)
	add_child(dialogue)

	assert_eq(dialogue.canvas_layer.offset, Vector2(-25, -25))
