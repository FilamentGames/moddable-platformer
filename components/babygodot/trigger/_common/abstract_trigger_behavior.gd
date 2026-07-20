@abstract
extends Node
class_name AbstractTriggerBehavior
## Abstract class that represents behavior run by a trigger area.

## This is executed by the parent `Quest Trigger` zone when the player enters the zone
@abstract func run_trigger() -> void
