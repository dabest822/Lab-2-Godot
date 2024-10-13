extends Node2D

@onready var sprite = $FallingVeggies  # Main falling veggie
@onready var audio_player = $VeggieCutSound  # Audio player for the cut sound
@onready var area = $Area2D  # Input detection

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 1.2  # Adjusted rotation speed

var is_cut = false
var velocity_left = Vector2()  # Velocity for the left half
var velocity_right = Vector2()  # Velocity for the right half

# Arrays to store the left and right cut pieces
@onready var cut_left_nodes = [
	$FallingCutVeggiesLeftG1,
	$FallingCutVeggiesLeftG2,
	$FallingCutVeggiesLeftG3,
	$FallingCutVeggiesLeftG4,
	$FallingCutVeggiesLeftG5
]

@onready var cut_right_nodes = [
	$FallingCutVeggiesRightG1,
	$FallingCutVeggiesRightG2,
	$FallingCutVeggiesRightG3,
	$FallingCutVeggiesRightG4,
	$FallingCutVeggiesRightG5
]

var selected_index = 0  # Store the index of the veggie type

func _ready():
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

	# Hide all cut pieces initially
	for left in cut_left_nodes:
		left.visible = false
	for right in cut_right_nodes:
		right.visible = false

	# Randomly select the index for the current veggie (between 0 and 4)
	selected_index = randi_range(0, 4)
	
	# Ensure the correct veggie sprite (left and right parts) is displayed
	update_sprite_to_match_veggie(selected_index)

func update_sprite_to_match_veggie(index):
	# Dynamically load the correct veggie visuals, based on the index
	var sprite_frames = load("res://Animations/VeggiesG%d.tres" % (index + 1)) as SpriteFrames

	if sprite_frames != null:
		sprite.frames = sprite_frames  # Matches veggie type

		# Assign the sprite frames to the cut nodes
		cut_left_nodes[index].frames = sprite_frames
		cut_right_nodes[index].frames = sprite_frames

		# Debug statement to track which sprite frames are being assigned
		print("Cut veggie type:", index + 1)
		print("Left piece assigned frames (node %d): %s" % [index, sprite_frames.resource_name])
		print("Right piece assigned frames (node %d): %s" % [index, sprite_frames.resource_name])

func _process(delta):
	if not is_cut:
		# Normal falling behavior
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)
	else:
		# Move cut pieces with smooth velocities
		cut_left_nodes[selected_index].position.x += velocity_left.x * delta
		cut_left_nodes[selected_index].position.y += velocity_left.y * delta

		cut_right_nodes[selected_index].position.x += velocity_right.x * delta
		cut_right_nodes[selected_index].position.y += velocity_right.y * delta

		# Rotate the cut pieces
		cut_left_nodes[selected_index].rotate(rotation_speed * delta)
		cut_right_nodes[selected_index].rotate(rotation_speed * delta)

func _on_veggie_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		cut()

func cut():
	if not is_cut:
		is_cut = true
		print("Cutting veggie!")

		if audio_player:
			audio_player.play()  # Play the cut sound

		# Hide the original veggie sprite
		sprite.hide()

		# Make the matching cut pieces visible
		cut_left_nodes[selected_index].visible = true
		cut_right_nodes[selected_index].visible = true

		# Set up velocities for the cut halves
		move_cut_halves()

		# Timer to remove the veggie after a delay
		var timer = Timer.new()
		timer.wait_time = 2.0  # Wait 2 seconds before removing the veggie
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_timeout"))
		timer.start()

func move_cut_halves():
	# Define the velocity for the two halves after the cut
	var move_direction_left = Vector2(-0.5, 1.0)  # Left half moves left
	var move_direction_right = Vector2(0.5, 1.0)  # Right half moves right
	var move_speed = fall_speed * 1.0  # The halves fall faster

	# Set the velocities
	velocity_left = move_direction_left * move_speed
	velocity_right = move_direction_right * move_speed

func _on_timeout():
	queue_free()  # Remove the veggie from the scene
