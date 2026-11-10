extends RefCounted
class_name SwordTriggerObject
## Helper method that lets us simulate a "trait" for sword-triggerable objects

## Returns true if an object can handle being hit by the player's sword
static func is_sword_trigger_object(obj: Node) -> bool:
	return "hit" in obj and obj.hit is Signal
	