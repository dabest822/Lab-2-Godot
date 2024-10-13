extends Node2D

@export var veggie_scene_path: String = "res://Scenes/Vegetables.tscn"
@export var base_spawn_interval: float = 0.6  # Faster spawn rate for veggies
@export var base_fall_speed: float = 250.0

var veggie_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

func _ready():
	print("Loading veggie scene from path: ", veggie_scene_path)  # Debugging print
	veggie_scene = load(veggie_scene_path)
	
	if veggie_scene == null:
		print("Error: Could not load veggie scene at path: ", veggie_scene_path)
		return  # Stop execution if the scene couldn't be loaded

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
		veggie_instance.position = Vector2(randf_range(100, viewport_size.x - 100), -50)

		# Debug position print
		print("Veggie instance spawned at position: ", veggie_instance.position)

		# Check if the veggie instance has the expected `fall_speed` variable
		if veggie_instance.has_meta("fall_speed"):  # Checking if it has the custom fall speed
			var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
			veggie_instance.set("fall_speed", base_fall_speed * speed_multiplier)
			print("Veggie spawned with fall speed: ", veggie_instance.get("fall_speed"))
		else:
			print("Warning: Veggie instance does not have 'fall_speed' metadata.")

		add_child(veggie_instance)
	else:
		print("Error: veggie_scene is null, could not instantiate veggie.")

func _process(_delta):
	for veggie_instance in get_children():
		if veggie_instance is Node2D and veggie_instance.has_node("FallingVeggies"):
			if veggie_instance.position.y > viewport_size.y + 50:
				veggie_instance.queue_free()
				print("Veggie instance went off-screen and was removed.")
