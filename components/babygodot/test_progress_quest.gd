extends Node

func _exit_tree():
	InGameQuestsBridge.progress_quest()
