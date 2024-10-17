extends Node2D

@export var bomb_scene_path: String = "res://Scenes/Bombs.tscn"
@export var base_spawn_interval: float = 5.0  # Initial spawn interval
@export var min_spawn_interval: float = 0.5  # Smallest allowed spawn interval
@export var base_fall_speed: float = 250.0
@export var bomb_spawn_delay: float = 2.0  # Delay before starting to spawn bombs

var bomb_scene: PackedScene
var spawn_timer: Timer
var delay_timer: Timer  # Timer to delay the bomb spawning
var current_bomb_count: int = 0  # Track how many bombs are currently on screen
var max_bombs_on_screen: int = 2  # Default to 2 bombs for easy difficulty

@onready var viewport_size = get_viewport().size

func _ready():
	bomb_scene = load(bomb_scene_path)

	# Timer for delay before starting to spawn bombs
	delay_timer = Timer.new()
	add_child(delay_timer)
	delay_timer.connect("timeout", Callable(self, "_start_bomb_spawning"))
	delay_timer.wait_time = bomb_spawn_delay
	delay_timer.start()

	print("Bomb spawning delayed by ", bomb_spawn_delay, " seconds.")

func _start_bomb_spawning():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_try_spawn_bomb"))
	spawn_timer.one_shot = true
	update_difficulty()
	spawn_timer.start()

func update_difficulty():
	var difficulty = GlobalState.current_difficulty
	var new_spawn_interval = base_spawn_interval / (1 + (difficulty - 1) * 0.3)
	spawn_timer.wait_time = max(min_spawn_interval, new_spawn_interval)
	spawn_timer.start()

	# Adjust max bombs on screen based on difficulty
	match difficulty:
		1:  # Easy difficulty
			max_bombs_on_screen = 2
		2:  # Medium difficulty
			max_bombs_on_screen = 3
		3:  # Hard difficulty
			max_bombs_on_screen = 4

	print("Spawn interval set to: ", spawn_timer.wait_time)
	print("Max bombs on screen set to: ", max_bombs_on_screen)

func _try_spawn_bomb():
	# Only spawn a bomb if the current number of bombs is less than the maximum allowed
	if current_bomb_count < max_bombs_on_screen and bomb_scene:
		_spawn_bomb()

	# Restart the timer regardless
	spawn_timer.start()
	print("Spawn timer restarted.")

func _spawn_bomb():
	var bomb_instance = bomb_scene.instantiate()
	bomb_instance.position = Vector2(randf_range(100, viewport_size.x - 100), -50)

	var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
	bomb_instance.fall_speed = base_fall_speed * speed_multiplier

	# Connect the bomb_hit signal
	bomb_instance.connect("bomb_hit", Callable(self, "_on_bomb_hit"))

	add_child(bomb_instance)  # Add the bomb to the scene first
	current_bomb_count += 1  # Increase bomb count
	print("Bomb spawned with fall speed: ", bomb_instance.fall_speed)

	# Connect the tree_exited signal to handle bomb removal
	if bomb_instance.connect("tree_exited", Callable(self, "_on_bomb_removed")):
		print("Successfully connected tree_exited signal for bomb")
	else:
		print("Failed to connect tree_exited signal for bomb")

func _on_bomb_removed():
	current_bomb_count -= 1
	current_bomb_count = max(current_bomb_count, 0)  # Prevent negative values
	print("Bomb removed, current bomb count: ", current_bomb_count)

func _on_bomb_hit():
	var level_controller = get_parent()
	if level_controller and level_controller.has_method("on_bomb_hit"):
		level_controller.on_bomb_hit()
	else:
		print("Error: Level controller not found or doesn't have on_bomb_hit method")

func _process(_delta):
	pass
