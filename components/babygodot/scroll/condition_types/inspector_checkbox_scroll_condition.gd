@tool
extends ScrollCondition
## A basic proof-of-concept scroll condition, you just have to check a box in the inspector to get it to pass!

## Check this box to get the scroll!
@export var can_i_get_the_scroll := false

func is_condition_met() -> bool:
	return can_i_get_the_scroll

func get_label_text() -> String:
	var path := get_parent().name + "/" + name
	return "Select the object: [code]" + path + "[/code] and click the \"Can I Get The Scroll\" box in the inspector tab."
