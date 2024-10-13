extends Node2D

@onready var sprite = $FallingVeggies  # Main falling veggie
@onready var cut_sprite_left = $FallingCutVeggiesLeft  # Left cut version of the veggie
@onready var cut_sprite_right = $FallingCutVeggiesRight  # Right cut version of the veggie
@onready var audio_player = $VeggieCutSound  # Audio player for the cut sound
@onready var area = $Area2D  # Input detection

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0

var is_cut = false
var velocity_left = Vector2()  # Velocity for the left half
var velocity_right = Vector2()  # Velocity for the right half

func _ready():
	# Randomly assign a veggie animation
	var veggie_types = ["BellPepper", "Broccoli", "Cabbage", "Carrot", "Cauliflower", 
						"Corn", "Eggplant", "HotPepper", "Leek", "Lettuce", "Mushroom", 
						"Onion", "Potato", "Pumpkin", "Tomato"]
	var random_veggie = veggie_types[randi() % veggie_types.size()]
	sprite.play(random_veggie)
	cut_sprite_left.play(random_veggie)
	cut_sprite_right.play(random_veggie)

	# Hide the cut versions at start
	cut_sprite_left.hide()
	cut_sprite_right.hide()

	# Enable input on the veggie
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

func _process(delta):
	# Continue regular falling if not yet cut
	if not is_cut:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)
	else:
		# Apply movement for the cut halves
		cut_sprite_left.position += velocity_left * delta
		cut_sprite_right.position += velocity_right * delta

func _on_veggie_clicked(_viewport, event, _shape_idx):
	# Debug to mark when a veggie is clicked
	print("Veggie clicked at: ", Time.get_ticks_msec())

	# Check if the event is a mouse button click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		cut()

func cut():
	if not is_cut:
		is_cut = true
		sprite.hide()  # Hide the main falling veggie sprite
		
		# Play the cut sound immediately
		if audio_player:
			audio_player.play()
			# Debug to mark when the sound is played
			print("Sound played at: ", Time.get_ticks_msec())
		
		# Show the cut veggies
		show_cut_veggies()

		# Remove the veggie node after 2 seconds (after the cut pieces fall)
		await get_tree().create_timer(2.0).timeout
		queue_free()

func show_cut_veggies():
	# Set positions of cut sprites to match original position
	cut_sprite_left.position = sprite.position
	cut_sprite_right.position = sprite.position

	# Sync animation and frame for left and right halves
	cut_sprite_left.animation = sprite.animation  # Set animation name
	cut_sprite_right.animation = sprite.animation
	cut_sprite_left.frame = sprite.frame          # Set frame number
	cut_sprite_right.frame = sprite.frame

	# Apply shader for each half properly
	var left_material = cut_sprite_left.material as ShaderMaterial
	var right_material = cut_sprite_right.material as ShaderMaterial

	if left_material and right_material:
		left_material.set_shader_parameter("is_left_side", true)   # Left sprite shows left half
		right_material.set_shader_parameter("is_left_side", false) # Right sprite shows right half

		# Debugging to verify shader parameters are set correctly
		print("Left sprite shader is_left_side: ", left_material.get_shader_parameter("is_left_side"))
		print("Right sprite shader is_left_side: ", right_material.get_shader_parameter("is_left_side"))
	else:
		print("Error: ShaderMaterial not assigned correctly.")

	# Show both the left and right cut sprites
	cut_sprite_left.show()
	cut_sprite_right.show()

	# Start moving the veggie halves
	move_cut_halves()

func move_cut_halves():
	# Move left and right halves in slightly less extreme directions
	var move_direction_left = Vector2(-0.3, 1)  # Move down-left, less extreme
	var move_direction_right = Vector2(0.3, 1)  # Move down-right, less extreme
	var move_speed = fall_speed * 0.8  # Reduced speed for a more natural fall

	# Set velocities for each half
	velocity_left = move_direction_left * move_speed
	velocity_right = move_direction_right * move_speed
