@tool
extends Control

@onready var quest_name_label: Label = %QuestNameLabel
@onready var quest_description_label: Label = %QuestDescriptionLabel
@onready var current_step_label: Label = %CurrentStepLabel
@onready var next_step_label: Label = %NextStepLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var avatar_texture: TextureRect = %AvatarTexture