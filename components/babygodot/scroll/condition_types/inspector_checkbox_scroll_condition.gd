@tool
extends ScrollCondition
## A basic proof-of-concept scroll condition, you just have to check a box in the inspector to get it to pass!

## Check this box to get the scroll!
@export var can_i_get_the_yarnspark := false

func is_condition_met() -> bool:
	return can_i_get_the_yarnspark

func get_label_text() -> String:
	return "The [color=#a663b5]Can I Get The Yarnspark[/color] property of the [color=#a663b5]Yarnspark[/color] node must be enabled"
