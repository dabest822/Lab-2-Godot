extends Node2D  # Since it's attached to a Node2D

var timer_label: Label  # Label to display the timer
var time_remaining: float = 0.0
var countdown_speed: float = 1.0  # Adjust for difficulty: 1.0 means 1 second per real second

func _ready():
	# Set the current level in GlobalState based on the active scene name
	var scene_name = get_tree().current_scene.name
	print("Current scene name is: ", scene_name)

	# Manually set the current level in GlobalState based on the actual scene names
	if scene_name == "Dojo":
		GlobalState.current_level = "Dojo"
	elif scene_name == "Mountain":
		GlobalState.current_level = "Mountain"
	elif scene_name == "TheGreatWave":  # Match the exact name from the console output
		GlobalState.current_level = "GreatWave"
	else:
		print("Warning: Unrecognized scene, no current level set.")

	# Get the CanvasLayer called "Timer" and find the correct label
	var canvas_layer = $Timer  # Reference the CanvasLayer named "Timer"

	# Dynamically find the timer label based on the current level's structure
	if canvas_layer.has_node("LVL1Timer"):
		timer_label = canvas_layer.get_node("LVL1Timer")
		setup_timer_for_difficulty(1)  # Easy mode
	elif canvas_layer.has_node("LVL2Timer"):
		timer_label = canvas_layer.get_node("LVL2Timer")
		setup_timer_for_difficulty(2)  # Medium mode
	elif canvas_layer.has_node("LVL3Timer"):
		timer_label = canvas_layer.get_node("LVL3Timer")
		setup_timer_for_difficulty(3)  # Hard mode
	else:
		print("Warning: Timer label not found for this level")

	update_timer_display(time_remaining)
	set_process(true)  # Start updating the timer every frame

# Setup the timer for each difficulty level
func setup_timer_for_difficulty(difficulty: int):
	match difficulty:
		1:  # Easy Mode (180 seconds, normal speed)
			time_remaining = 18.0  # 3 minutes
			countdown_speed = 1.0  # Normal speed (1 second per real second)
		2:  # Medium Mode (150 seconds, faster countdown)
			time_remaining = 15.0  # 2 minutes 30 seconds
			countdown_speed = 0.8  # Countdown faster (0.8 seconds per real second)
		3:  # Hard Mode (120 seconds, even faster countdown)
			time_remaining = 12.0  # 2 minutes
			countdown_speed = 0.6  # Countdown even faster (0.6 seconds per real second)
	print("Starting level with difficulty: ", difficulty, " Timer: ", time_remaining, " Speed: ", countdown_speed)

# Process the timer every frame
func _process(delta):
	time_remaining -= delta / countdown_speed  # Adjust the delta by the countdown speed

	if time_remaining <= 0:
		time_remaining = 0
		stop_bombs()  # Stop bomb spawns and remove all bombs
		end_level()  # Switch to the Game Over screen
	
	update_timer_display(time_remaining)

# Update the timer display and change color based on remaining time
func update_timer_display(time_left: float):
	if timer_label:
		timer_label.text = str(int(time_left))  # Only display the remaining time in seconds
		
		# Change color to red if time is 10 seconds or less, otherwise keep it white
		if time_left <= 10:
			timer_label.modulate = Color(1, 0, 0)  # Red color (RGB: 1, 0, 0)
		else:
			timer_label.modulate = Color(1, 1, 1)  # White color (RGB: 1, 1, 1)

# Function to stop bombs from falling and remove all bombs
func stop_bombs():
	print("Timer reached zero. Stopping and removing all bombs...")

	# Stop the timer from processing further
	set_process(false)

	# Stop the BombSpawner from spawning new bombs
	var bomb_spawner = $BombSpawner  # Adjust this to match your BombSpawner node
	if bomb_spawner and bomb_spawner.has_method("set_process"):
		bomb_spawner.set_process(false)  # Stop BombSpawner from working

	# Remove all bombs that are currently on screen
	if bomb_spawner:
		for bomb in bomb_spawner.get_children():
			if bomb.has_method("queue_free"):
				bomb.queue_free()  # Remove all bombs from the scene

# Switch to the Game Over scene when the timer reaches zero
func end_level():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
