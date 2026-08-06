extends AbstractBridgeBehavior
class_name GateBridgeBehavior

## The gate that this behavior is associated with.
@export var gate: CollectibleGate

var bridge := InGameQuestsBridge.new()

func _ready() -> void:
	bridge.get_number_of_scrolls()
	bridge.scroll_quantity.connect(on_scroll_quantity_changed)

func on_scroll_quantity_changed(quantity: int) -> void:
	current_collectible_count = quantity
	is_ready = true

func mark_gate_opened(node: Node) -> void:
	InGameQuestsBridge.swap_node_with_prefab(node, gate.open_gate_prefab.resource_path)

func deplete_collectible() -> void:
	InGameQuestsBridge.deplete_scrolls(gate.required_collectibles)
