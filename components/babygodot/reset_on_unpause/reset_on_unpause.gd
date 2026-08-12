extends RefCounted
class_name ResetOnUnpause
## Helper class that contains "reset on unpause" behavior for things that we expect to reset on unpause as if we had reloaded the game from a fresh state.

## When objects are "sent to the shadow realm", this is where they are positioned off screen.
var hidden_position: Vector2 = Vector2(-0xdeadbeef, -0xdeadbeef)

var _bridge: InGameQuestsBridge

## The object that we want to reset
var _target: Node2D

## The initial position of the target when this component was created
var _initial_target_position: Vector2

## Whether the object is inert
var inert: bool = false

## Emitted when the reset function is called
signal on_reset()

func _init(node: Node2D, bridge_service: EditorGameMessagingService = GlobalMessagingService):
	_target = node
	_initial_target_position = Vector2(_target.position)
	_bridge = InGameQuestsBridge.new(bridge_service)

	_bridge.game_unpaused.connect(reset)

## Simulate deleting the object by not actually freeing them from the scene but instead sending them to the shadow realm.
func fake_free() -> void:
	_target.position = hidden_position
	_target.process_mode = Node.PROCESS_MODE_DISABLED
	_target.hide()
	inert = true

## Resets the object back to its initial position.
func reset() -> void:
	_target.position = _initial_target_position
	_target.process_mode = Node.PROCESS_MODE_INHERIT
	_target.show()
	inert = false
	on_reset.emit()
