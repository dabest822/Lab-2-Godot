extends Node

@onready var score_label = $Score
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

var animation_timer: Timer

func _ready():
	if not score_label:
		print("Error: Score label not found in the scene")
	reset_score()
	setup_animation_timer()
	if naruto_animation:
		naruto_animation.play("Idle")
	else:
		print("Warning: AnimationPlayer not found")

func setup_animation_timer():
	animation_timer = Timer.new()
	add_child(animation_timer)
	animation_timer.wait_time = 10.0  # Run every 10 seconds
	animation_timer.connect("timeout", Callable(self, "_on_animation_timer_timeout"))
	animation_timer.start()

func reset_score():
	score = 0
	bomb_hits = 0
	update_score_display()

func add_points(veggie_name: String):
	for category in VEGGIES:
		if veggie_name in VEGGIES[category]:
			score += VEGGIES[category][veggie_name]
			print("Added %d points for %s. New score: %d" % [VEGGIES[category][veggie_name], veggie_name, score])
			update_score_display()
			update_naruto_animation()
			return
	print("Unknown vegetable: %s" % veggie_name)

func hit_bomb():
	bomb_hits += 1
	score = max(0, score - BOMB_PENALTY)
	print("Hit bomb! Penalty: %d. New score: %d. Bomb hits: %d" % [BOMB_PENALTY, score, bomb_hits])
	update_score_display()
	if bomb_hits >= MAX_BOMB_HITS:
		game_over()
	else:
		naruto_animation.play("idle")

func game_over():
	print("Game Over! Too many bomb hits.")
	naruto_animation.play("idle")
	
	# Create a short delay before transitioning to the game-over scene
	var timer = Timer.new()
	timer.wait_time = 1.0  # 1-second delay
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout  # Wait until the timer times out
	change_to_game_over_scene()

func change_to_game_over_scene():
	if get_tree().has_current_scene():
		get_tree().change_scene("res://Scenes/GameOver.tscn")
	else:
		print("No current scene found.")

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
	if score > 200:
		naruto_animation.play("thumbsup")
	elif score > 100:
		naruto_animation.play("nodding")
	else:
		naruto_animation.play("idle")

func _on_animation_timer_timeout():
	if naruto_animation.current_animation == "idle":
		naruto_animation.play("running")
		await get_tree().create_timer(3.0).timeout  # Run for 3 seconds
		naruto_animation.play("idle")

func _on_veggie_cut(veggie_name):
	add_points(veggie_name)

func _on_bomb_hit():
	hit_bomb()
