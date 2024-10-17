extends Node2D

@export var veggie_scene_path: String = "res://Scenes/Vegetables.tscn"
@export var base_spawn_interval: float = 0.6  # Spawn rate for veggies
@export var base_fall_speed: float = 250.0

var veggie_scene: PackedScene
var spawn_timer: Timer

@onready var viewport_size = get_viewport().size

# Correct groups based on the images you shared
var veggie_groups = {
	"G1": ["Broccoli", "Eggplant", "Onion"],
	"G2": ["BellPepper", "Cabbage", "Corn", "HotPepper"],
	"G3": ["Carrot", "Leek", "Potato"],
	"G4": ["Cauliflower", "Mushroom", "Pumpkin"],
	"G5": ["Lettuce", "Tomato"]
}

# List of all veggie names for random selection
var all_veggie_names = []

func _ready():
	veggie_scene = load(veggie_scene_path)
	
	# Create and start the spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_spawn_veggie"))

	# Flatten the veggie_groups array into one list
	for group in veggie_groups.values():
		all_veggie_names += group

	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.start()

func _spawn_veggie():
	print("Attempting to spawn veggie...")
	
	if veggie_scene:
		var veggie_instance = veggie_scene.instantiate()
		var random_veggie = all_veggie_names[randi() % all_veggie_names.size()]

		veggie_instance.position = Vector2(randf_range(100, 1400), -50)

		# Set fall speed based on difficulty
		var speed_multiplier = 1 + (GlobalState.current_difficulty - 1) * 0.5
		veggie_instance.set("fall_speed", base_fall_speed * speed_multiplier)

		# Assign the group to the falling veggie
		var veggie_group = _determine_veggie_group(random_veggie)
		veggie_instance.set("current_group", veggie_group)  # Set the group for correct cut sprites

		# Set animation for the veggie
		var falling_sprite = veggie_instance.get_node("FallingVeggies")
		if falling_sprite:
			falling_sprite.play(random_veggie)
			print("Set veggie animation to: ", random_veggie)
		else:
			print("Error: Could not find FallingVeggies node in veggie_instance")

		# Connect the veggie_cut signal
		veggie_instance.connect("veggie_cut", Callable(self, "_on_veggie_cut"))
		
		add_child(veggie_instance)
		print("Spawned veggie type: ", random_veggie)
	else:
		print("Error: veggie_scene is null, could not instantiate veggie")

# Helper function to determine which group the veggie belongs to
func _determine_veggie_group(veggie_name):
	for group_name in veggie_groups.keys():
		if veggie_name in veggie_groups[group_name]:
			return group_name
	return ""

func _on_veggie_cut(veggie_name):
	print("Veggie was cut: ", veggie_name)  # Directly handle the veggie_cut signal

func _process(_delta):
	pass
