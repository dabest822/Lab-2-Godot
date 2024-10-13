extends Node2D

@onready var sprite = $FallingVeggies  # Main falling veggie
@onready var cut_sprite = $FallingCutVeggies  # Cut version of the veggie
@onready var audio_player = $VeggieCutSound  # Audio player for the cut sound
@onready var area = $Area2D  # Input detection

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0

var is_cut = false

func _ready():
	# Randomly assign a veggie animation
	var veggie_types = ["BellPepper", "Broccoli", "Cabbage", "Carrot", "Cauliflower", 
						"Corn", "Eggplant", "HotPepper", "Leek", "Lettuce", "Mushroom", 
						"Onion", "Potato", "Pumpkin", "Tomato"]
	var random_veggie = veggie_types[randi() % veggie_types.size()]
	sprite.play(random_veggie)
	cut_sprite.play(random_veggie)

	# Hide the cut version at start
	cut_sprite.hide()

	# Enable input on the veggie
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

func _process(delta):
	if not is_cut:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)

func _on_veggie_clicked(_viewport, event, _shape_idx):
	if event.is_action_pressed("Click"):
		cut()

func cut():
	if not is_cut:
		is_cut = true
		sprite.hide()  # Hide the falling veggie
		
		# Play the cut sound immediately
		if audio_player:
			audio_player.play()
		
		show_cut_veggie()  # Show cut version and start animation

		# Remove veggie after 2 seconds
		await get_tree().create_timer(2.0).timeout
		queue_free()

func show_cut_veggie():
	cut_sprite.show()  # Show the cut sprite

	# Apply shader for the left half
	cut_sprite.material.set("shader_param/is_left_side", true)

	# Start moving the veggie halves
	move_cut_halves()

func move_cut_halves():
	var move_direction_left = Vector2(-1, 1)  # Move left half down and left
	var move_direction_right = Vector2(1, 1)  # Move right half down and right
	var move_speed = fall_speed * 0.8
	var delta_time = 0.02

	# Simulate the movement
	await get_tree().create_timer(delta_time).timeout
	
	# Move the left half first
	cut_sprite.position += move_direction_left * move_speed * delta_time
	cut_sprite.material.set("shader_param/is_left_side", false)  # Switch to right side
	
	# Move the right half
	cut_sprite.position += move_direction_right * move_speed * delta_time
