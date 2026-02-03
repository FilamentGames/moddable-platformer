@tool
extends Control
## Docked window that displays quest information, progress, and character avatar

@onready var quest_name_label: Label = %QuestNameLabel
@onready var quest_description_label: Label = %QuestDescriptionLabel
@onready var current_step_label: Label = %CurrentStepLabel
@onready var next_step_label: Label = %NextStepLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var avatar_texture: TextureRect = %AvatarTexture

var current_quest: Quest = null

func _ready():
	# Set up initial UI state
	update_quest_display(null)

## Update the quest display with new quest data
func update_quest_display(quest: Quest):
	current_quest = quest
	
