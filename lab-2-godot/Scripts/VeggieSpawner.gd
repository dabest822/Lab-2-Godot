extends Node2D

@export var veggie_scene_path: String = "res://Scenes/Vegetables.tscn"
@export var base_spawn_interval: float = 0.6
@export var base_fall_speed: float = 250.0

var veggie_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

func _ready():
	print("VeggieSpawner initializing...")
	load_veggie_scene()
	setup_spawn_timer()

func load_veggie_scene():
	print("Loading veggie scene from path: ", veggie_scene_path)
	veggie_scene = load(veggie_scene_path)
	if veggie_scene == null:
		print("Error: Could not load veggie scene at path: ", veggie_scene_path)

func setup_spawn_timer():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.connect("timeout", Callable(self, "_spawn_veggie"))
	spawn_timer.start()
	print("Spawn timer started with interval: ", base_spawn_interval)

func _spawn_veggie():
	if veggie_scene:
		var veggie_instance = veggie_scene.instantiate()
		configure_veggie(veggie_instance)
		add_child(veggie_instance)
	else:
		print("Error: veggie_scene is null, could not instantiate veggie.")

func configure_veggie(veggie):
	veggie.position = Vector2(randf_range(100, viewport_size.x - 100), -50)
	
	var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.25
	veggie.fall_speed = base_fall_speed * speed_multiplier
	veggie.rotation_speed = randf_range(1.0, 3.0)  # Random rotation speed
	print("Veggie spawned at position: ", veggie.position, " with fall speed: ", veggie.fall_speed)

func _process(_delta):
	remove_offscreen_veggies()

func remove_offscreen_veggies():
	for veggie in get_children():
		if veggie is Node2D and veggie.has_node("FallingVeggies"):
			if veggie.position.y > viewport_size.y + 50:
				veggie.queue_free()
				print("Veggie instance went off-screen and was removed.")
