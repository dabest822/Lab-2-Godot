extends Node

var start_in_level_select: bool = false
var current_difficulty: int = 1
var current_level: String = ""
var score: int = 0
var bomb_hits: int = 0
const MAX_BOMB_HITS: int = 3

var level_difficulties = {
	"res://Scenes/Level 1 (Dojo).tscn": 1,  # Easy
	"res://Scenes/Level 2 (Mountain).tscn": 2,  # Normal
	"res://Scenes/Level 3 (The Great Wave).tscn": 3   # Hard
}

var high_scores = {
	"res://Scenes/Level 1 (Dojo).tscn": 0,
	"res://Scenes/Level 2 (Mountain).tscn": 0,
	"res://Scenes/Level 3 (The Great Wave).tscn": 0
}

func set_difficulty_by_level(level_path: String):
	if level_path in level_difficulties:
		current_difficulty = level_difficulties[level_path]
	else:
		current_difficulty = 1  # Default to easy if level not found
	print("Difficulty set to: ", current_difficulty)

func update_high_score(level_path: String, new_score: int):
	if level_path in high_scores and new_score > high_scores[level_path]:
		high_scores[level_path] = new_score
		save_high_scores()

func save_high_scores():
	var file = FileAccess.open("user://high_scores.save", FileAccess.WRITE)
	file.store_var(high_scores)
	file.close()

func load_high_scores():
	if FileAccess.file_exists("user://high_scores.save"):
		var file = FileAccess.open("user://high_scores.save", FileAccess.READ)
		high_scores = file.get_var()
		file.close()

func reset_score():
	score = 0
	bomb_hits = 0

func _ready():
	load_high_scores()
