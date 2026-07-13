@tool
extends Node
class_name EditableNodeList
## Holds the list of nodes in the scene that can be seen/edited by the player.
## The streamlined editor is programmed to detect this node and reads the nodes property to determine which nodes can be edited/displayed in the scene tree.

## The nodes that can be edited by the player for this scene. If this value is empty, all nodes in the scene will be editable.
@export var nodes: Array[Node] = []
