@tool
extends EditorPlugin

func _enter_tree():
	print("Baby Godot plugin enabled")

func _exit_tree():
	print("Baby Godot plugin disabled")
