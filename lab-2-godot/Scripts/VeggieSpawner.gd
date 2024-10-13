extends Node2D

@export var veggie_scene_path: String = "res://Scenes/Vegetables.tscn"
@export var base_spawn_interval: float = 0.6  # Faster spawn rate for veggies
@export var base_fall_speed: float = 250.0

var veggie_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

var veggie_split_offsets = {
	"BellPepper": 0.3,
	"Broccoli": 0.5,
	"Cabbage": 0.3,
	"Carrot": 0.7,
	"Cauliflower": 0.9,
	"Corn": 0.3,
	"Eggplant": 0.5,
	"HotPepper": 0.3,
	"Leek": 0.7,
	"Lettuce": 0.1,
	"Mushroom": 0.9,
	"Onion": 0.5,
	"Potato": 0.7,
	"Pumpkin": 0.9,
	"Tomato": 0.1
}

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
		var veggie_types = ["BellPepper", "Broccoli", "Cabbage", "Carrot", "Cauliflower", 
						"Corn", "Eggplant", "HotPepper", "Leek", "Lettuce", "Mushroom", 
						"Onion", "Potato", "Pumpkin", "Tomato"]
		var random_veggie = veggie_types[randi() % veggie_types.size()]
		
		veggie_instance.position = Vector2(randf_range(100, viewport_size.x - 100), -50)  # Random X position
		
		# Apply fall speed based on difficulty
		var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
		veggie_instance.set("fall_speed", base_fall_speed * speed_multiplier)
		
		# Set the appropriate split offset based on veggie type
		veggie_instance.set("split_offset", veggie_split_offsets.get(random_veggie, 0.0))

		# Access the correct AnimatedSprite2D node within the veggie instance
		var falling_sprite = veggie_instance.get_node("FallingVeggies")
		if falling_sprite:
			falling_sprite.play(random_veggie)
			print("Set veggie animation to: ", random_veggie)
		else:
			print("Error: Could not find FallingVeggies node in veggie_instance")

		add_child(veggie_instance)
		print("Spawned veggie type: ", random_veggie)
