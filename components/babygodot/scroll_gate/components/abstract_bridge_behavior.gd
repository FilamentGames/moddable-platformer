@abstract
extends Node
class_name AbstractBridgeBehavior
## Represents an object that the collectible gate can use to query the global game state. In production, this object will use the InGameQuestsBridge.

## Set to true when the behavior has been initialized and is ready to be used.
var is_ready: bool = false

## The current number of collectibles that have been collected.
var current_collectible_count: int = 0

@abstract func mark_gate_opened(node: Node) -> void
@abstract func deplete_collectible() -> void