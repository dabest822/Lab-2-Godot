extends Node2D

var timer_label: Label
var time_remaining: float = 0.0
var countdown_speed: float = 1.0
var sword_slash_scene = preload("res://Scenes/Sword.tscn")
var current_slash: Sprite2D = null

var score: int = 0
var bomb_hits: int = 0
const MAX_BOMB_HITS: int = 3

@onready var score_label = $Scoring/Score

func _ready():
	setup_current_level()
	setup_timer()
	setup_sword_slash()
	setup_score_manager()
	set_process(true)

func setup_current_level():
	var scene_name = get_tree().current_scene.name
	print("Current scene name is: ", scene_name)
	match scene_name:
		"Dojo": GlobalState.current_level = "Dojo"
		"Mountain": GlobalState.current_level = "Mountain"
		"TheGreatWave": GlobalState.current_level = "GreatWave"
		_: print("Warning: Unrecognized scene, no current level set.")

func setup_timer():
	var canvas_layer = $Timer
	var difficulty = 1
	if canvas_layer.has_node("LVL1Timer"):
		timer_label = canvas_layer.get_node("LVL1Timer")
		difficulty = 1
	elif canvas_layer.has_node("LVL2Timer"):
		timer_label = canvas_layer.get_node("LVL2Timer")
		difficulty = 2
	elif canvas_layer.has_node("LVL3Timer"):
		timer_label = canvas_layer.get_node("LVL3Timer")
		difficulty = 3
	else:
		print("Warning: Timer label not found for this level")
	
	setup_timer_for_difficulty(difficulty)
	update_timer_display(time_remaining)

func setup_timer_for_difficulty(difficulty: int):
	match difficulty:
		1: time_remaining = 180.0; countdown_speed = 1.0
		2: time_remaining = 150.0; countdown_speed = 0.8
		3: time_remaining = 120.0; countdown_speed = 0.6
	print("Starting level with difficulty: ", difficulty, " Timer: ", time_remaining, " Speed: ", countdown_speed)

func setup_sword_slash():
	var sword_instance = sword_slash_scene.instantiate()
	add_child(sword_instance)
	current_slash = sword_instance.get_node("SwordSlash")

func setup_score_manager():
	score = 0
	bomb_hits = 0
	update_score_display()

func _process(delta):
	time_remaining -= delta / countdown_speed
	if time_remaining <= 0:
		time_remaining = 0
		stop_bombs()
		end_level()
	update_timer_display(time_remaining)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_slash and not current_slash.is_active:
			current_slash.show_slash(get_global_mouse_position())

func update_timer_display(time_left: float):
	if timer_label:
		timer_label.text = str(int(time_left))
		timer_label.modulate = Color(1, 0, 0) if time_left <= 10 else Color(1, 1, 1)

func stop_bombs():
	print("Timer reached zero. Stopping and removing all bombs...")
	set_process(false)
	var bomb_spawner = $BombSpawner
	if bomb_spawner and bomb_spawner.has_method("set_process"):
		bomb_spawner.set_process(false)
	if bomb_spawner:
		for bomb in bomb_spawner.get_children():
			if bomb.has_method("queue_free"):
				bomb.queue_free()

func end_level():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func add_points(_veggie_name: String):
	# Add logic to determine points based on veggie type
	var points = 10  # Default points, adjust as needed
	score += points
	update_score_display()

func hit_bomb():
	bomb_hits += 1
	score = max(0, score - 30)  # Subtract 30 points, don't go below 0
	update_score_display()
	if bomb_hits >= MAX_BOMB_HITS:
		end_level()

func update_score_display():
	if score_label:
		score_label.text = "Score: %d" % score
	else:
		print("Warning: score_label not found")

# These functions should be called from VeggieSpawner and BombSpawner
func on_veggie_cut(veggie_name):
	add_points(veggie_name)

func on_bomb_hit():
	hit_bomb()
