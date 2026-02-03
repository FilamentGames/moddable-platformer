@tool
extends EditorPlugin

const PROFILE_NAME = "bgd"
const PROFILE_SOURCE_PATH = "res://addons/bgd/bgd.profile"

func _enter_tree():
	print("Baby Godot plugin enabled")

func _exit_tree():
	print("Baby Godot plugin disabled")
