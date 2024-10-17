extends Control

@onready var dojo_high_score_label = $DojoHS
@onready var mountain_high_score_label = $MountainHS
@onready var wave_high_score_label = $TheGreatWaveHS

func _ready():
	update_high_score_labels()

func update_high_score_labels():
	var global_state = get_node("/root/GlobalState")
	if global_state:
		dojo_high_score_label.text = "High Score: %d" % global_state.high_scores.get("res://Scenes/Level 1 (Dojo).tscn", 0)
		mountain_high_score_label.text = "High Score: %d" % global_state.high_scores.get("res://Scenes/Level 2 (Mountain).tscn", 0)
		wave_high_score_label.text = "High Score: %d" % global_state.high_scores.get("res://Scenes/Level 3 (The Great Wave).tscn", 0)
	else:
		print("GlobalState not found!")
