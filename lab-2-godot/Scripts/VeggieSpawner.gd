extends Node2D

@export var veggie_scene_path: String = "res://Scenes/Vegetables.tscn"
@export var base_spawn_interval: float = 0.6  # Faster spawn rate for veggies
@export var base_fall_speed: float = 250.0

var veggie_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

func _ready():
	veggie_scene = load(veggie_scene_path)
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_spawn_veggie"))
	
	# Start spawning veggies immediately
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.start()

func _spawn_veggie():
	print("Attempting to spawn veggie...")  # Debugging print statement
	if veggie_scene:
		var veggie_instance = veggie_scene.instantiate()
		veggie_instance.position = Vector2(randf_range(100, viewport_size.x - 100), -50)  # Random X position
		
		# Apply fall speed based on difficulty
		var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
		veggie_instance.set("fall_speed", base_fall_speed * speed_multiplier)
		
		add_child(veggie_instance)
		print("Veggie spawned with fall speed: ", veggie_instance.get("fall_speed"), " at position: ", veggie_instance.position)
