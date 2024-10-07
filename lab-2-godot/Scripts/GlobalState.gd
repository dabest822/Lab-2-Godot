extends Node

var start_in_level_select: bool = false
var current_difficulty: int = 1

# Map levels to difficulties
var level_difficulties = {
	"res://Scenes/Level 1 (Dojo).tscn": 1,  # Easy
	"res://Scenes/Level 2 (Mountain).tscn": 2,  # Normal
	"res://Scenes/Level 3 (The Great Wave).tscn": 3   # Hard
}

func set_difficulty_by_level(level_path: String):
	if level_path in level_difficulties:
		current_difficulty = level_difficulties[level_path]
	else:
		current_difficulty = 1  # Default to easy if level not found
	print("Difficulty set to: ", current_difficulty)
