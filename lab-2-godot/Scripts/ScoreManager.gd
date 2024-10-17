extends Node

@onready var score_label = $Score
@onready var high_score_dojo_label = $DojoHS
@onready var high_score_mountain_label = $MountainHS
@onready var high_score_wave_label = $TheGreatWaveHS
@onready var naruto = $NarutoDancing
@onready var naruto_animation = $NarutoDancing/AnimationPlayer

const VEGGIES = {
	"common": {
		"Broccoli": 10, "Eggplant": 10, "Onion": 10, "BellPepper": 10,
		"Carrot": 10, "Lettuce": 10, "Tomato": 10
	},
	"uncommon": {
		"Cabbage": 25, "Corn": 25, "Leek": 25, "Cauliflower": 25, "Mushroom": 25
	},
	"rare": {
		"HotPepper": 50, "Potato": 50, "Pumpkin": 50
	}
}

var score: int = 0
var bomb_hits: int = 0
const MAX_BOMB_HITS: int = 3
const BOMB_PENALTY: int = 30

const COMMON_SPAWN_CHANCE: float = 0.7
const UNCOMMON_SPAWN_CHANCE: float = 0.25
const RARE_SPAWN_CHANCE: float = 0.05

# New constants for animation control
const ANIMATION_CHECK_INTERVAL: float = 10.0  # Time between animation checks (in seconds)
const SCORE_THRESHOLD_NOD: int = 125  # Score needed to trigger nodding animation
const SCORE_THRESHOLD_THUMBS_UP: int = 225  # Score needed to trigger thumbs up animation

var animation_timer: Timer
var did_initial_run: bool = false
var did_nod: bool = false
var did_thumbs_up: bool = false

func _ready():
	if not score_label:
		print("Error: Score label not found in the scene")
	reset_score()
	setup_animation_timer()
	update_score_display()
	update_high_score_displays()  # Make sure the high score is updated at start

	if naruto_animation:
		naruto_animation.connect("animation_finished", Callable(self, "_on_animation_finished_idle"))
		start_initial_naruto_run()
	else:
		print("Warning: AnimationPlayer not found")

func setup_animation_timer():
	animation_timer = Timer.new()
	add_child(animation_timer)
	animation_timer.wait_time = ANIMATION_CHECK_INTERVAL
	animation_timer.connect("timeout", Callable(self, "_on_animation_timer_timeout"))
	animation_timer.start()

func reset_score():
	score = 0
	bomb_hits = 0
	update_score_display()
	did_initial_run = false
	did_nod = false
	did_thumbs_up = false

func set_animation_speed(animation_name: String, speed: float):
	if naruto_animation.has_animation(animation_name):
		naruto_animation.set_speed_scale(speed)
	else:
		print("Warning: Animation '%s' not found" % animation_name)

func start_initial_naruto_run():
	if not did_initial_run:
		did_initial_run = true
		set_animation_speed("Running", 1.5)  # Adjust this value to change speed
		naruto_animation.play("Running")
		var tween = create_tween()
		tween.tween_property(naruto, "position:x", 180, 2.0)
		tween.tween_callback(Callable(self, "_on_initial_run_finished"))

func _on_initial_run_finished():
	set_animation_speed("Idle", 1.0)
	naruto_animation.play("Idle")

func add_points(veggie_name: String):
	for category in VEGGIES:
		if veggie_name in VEGGIES[category]:
			score += VEGGIES[category][veggie_name]
			print("Added %d points for %s. New score: %d" % [VEGGIES[category][veggie_name], veggie_name, score])
			update_score_display()
			update_naruto_animation()
			check_high_score()  # Update high score if needed
			return
	print("Unknown vegetable: %s" % veggie_name)

func hit_bomb():
	bomb_hits += 1
	score = max(0, score - BOMB_PENALTY)
	print("Hit bomb! Penalty: %d. New score: %d. Bomb hits: %d" % [BOMB_PENALTY, score, bomb_hits])
	update_score_display()
	set_animation_speed("HitBomb", 0.35)  # Adjust this value to change speed
	naruto_animation.play("HitBomb")

	if bomb_hits >= MAX_BOMB_HITS:
		game_over()

func game_over():
	print("Game Over! Too many bomb hits.")
	set_animation_speed("Idle", 1.0)
	naruto_animation.play("Idle")

	# Create a short delay before transitioning to the game-over scene
	var timer = Timer.new()
	timer.wait_time = 1.0  # 1-second delay
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout  # Wait until the timer times out
	change_to_game_over_scene()

func change_to_game_over_scene():
	if get_tree().root != null:
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
	else:
		print("No current scene found.")

func check_high_score():
	var global_state = get_node("/root/GlobalState")  # Ensure GlobalState is accessible
	if global_state:
		global_state.update_high_score(global_state.current_level, score)
		update_high_score_displays()

func update_high_score_displays():
	if high_score_dojo_label:
		high_score_dojo_label.text = "Dojo High Score: %d" % GlobalState.high_scores["res://Scenes/Level 1 (Dojo).tscn"]
	if high_score_mountain_label:
		high_score_mountain_label.text = "Mountain High Score: %d" % GlobalState.high_scores["res://Scenes/Level 2 (Mountain).tscn"]
	if high_score_wave_label:
		high_score_wave_label.text = "Wave High Score: %d" % GlobalState.high_scores["res://Scenes/Level 3 (The Great Wave).tscn"]

func get_random_veggie():
	var rand = randf()
	var category
	if rand < COMMON_SPAWN_CHANCE:
		category = "common"
	elif rand < COMMON_SPAWN_CHANCE + UNCOMMON_SPAWN_CHANCE:
		category = "uncommon"
	else:
		category = "rare"
	
	var veggies = VEGGIES[category].keys()
	return veggies[randi() % veggies.size()]

func update_score_display():
	if score_label:
		score_label.text = "Score: %d" % score
	else:
		print("Warning: Score label not found")

func update_naruto_animation():
	if score >= SCORE_THRESHOLD_THUMBS_UP and not did_thumbs_up:
		did_thumbs_up = true
		set_animation_speed("ThumbsUp", 0.6)  # Adjust this value to change speed
		naruto_animation.play("ThumbsUp")
	elif score >= SCORE_THRESHOLD_NOD and not did_nod:
		did_nod = true
		set_animation_speed("Nodding", 0.6)  # Adjust this value to change speed
		naruto_animation.play("Nodding")
	else:
		set_animation_speed("Idle", 1.0)  # Adjust this value to change speed
		naruto_animation.play("Idle")

func _on_animation_timer_timeout():
	if naruto_animation.current_animation == "Idle":
		set_animation_speed("Idle", 1.0)  # Adjust this value to change speed
		naruto_animation.play("Idle")  # Just to ensure Naruto stays in Idle

func _on_animation_finished_idle(_anim_name: String):
	if naruto_animation.current_animation != "Idle":
		set_animation_speed("Idle", 1.0)  # Adjust this value to change speed
		naruto_animation.play("Idle")

func _on_veggie_cut(veggie_name: String):
	add_points(veggie_name)

func _on_bomb_hit():
	hit_bomb()

func setup_bomb_signal(bomb_instance):
	bomb_instance.connect("bomb_hit", Callable(self, "_on_bomb_hit"))
