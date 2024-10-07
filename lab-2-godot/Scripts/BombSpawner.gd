extends Node2D

@export var bomb_scene_path: String = "res://Scenes/Bombs.tscn"
@export var base_spawn_interval: float = 3.0  # Increased to reduce frequency
@export var base_fall_speed: float = 250.0

var bomb_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

func _ready():
	bomb_scene = load(bomb_scene_path)
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_spawn_bomb"))
	update_difficulty()

func update_difficulty():
	var difficulty = GlobalState.current_difficulty
	# Adjust spawn rate based on difficulty, but keep it relatively slow
	spawn_timer.wait_time = base_spawn_interval / (1 + (difficulty - 1) * 0.2)
	spawn_timer.start()
	print("Spawn interval set to: ", spawn_timer.wait_time)

func _spawn_bomb():
	if bomb_scene:
		var bomb_instance = bomb_scene.instantiate()
		bomb_instance.position = Vector2(randf_range(0, viewport_size.x), -50)
		
		var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
		bomb_instance.fall_speed = base_fall_speed * speed_multiplier
		
		add_child(bomb_instance)
		print("Bomb spawned with fall speed: ", bomb_instance.fall_speed)

func _process(_delta):
	for bomb_instance in get_children():
		if bomb_instance is Node2D and bomb_instance.has_node("FallingBombs"):
			if bomb_instance.position.y > viewport_size.y + 50:
				bomb_instance.queue_free()
