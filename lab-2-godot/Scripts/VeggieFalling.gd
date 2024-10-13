extends Node2D

@onready var sprite = $FallingVeggies  # The main sprite for the veggie
@onready var audio_player = $VeggieCutSound  # Reference to the audio player
@onready var area = $Area2D  # Reference to Area2D for click detection

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0  # Rotation speed as it falls

var is_cut = false

func _ready():
	# Make the area input pickable for the mouse clicks
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

func _process(delta):
	if not is_cut:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)  # Rotate while falling

# Handling the click
func _on_veggie_clicked(_viewport, event, _shapeidx):
	if event.is_action_pressed("Click"):
		print("Veggie clicked!")
		cut()

# Cutting the veggie (will apply the shader to cut)
func cut():
	if not is_cut:
		is_cut = true
		sprite.hide()  # Hide the main veggie sprite
		show_cut_veggie()  # Show the cut version of the veggie

		if audio_player:
			audio_player.play()

		# After showing the cut halves, queue free the veggie after 2 seconds
		await get_tree().create_timer(2.0).timeout
		queue_free()

# Show the cut veggie
func show_cut_veggie():
	sprite.show()
	# Apply the cut shader (this will either show the left or right half)
	sprite.material.set("shader_param/is_left_side", true)  # Apply left side first
	move_cut_halves()

# Function to animate the veggie halves as they move apart and fall
func move_cut_halves():
	var move_direction_left = Vector2(-1, 1)  # Left half moves left and down
	var move_direction_right = Vector2(1, 1)  # Right half moves right and down
	var move_speed = fall_speed * 0.8  # Slower fall speed for cut halves

	var delta_time = 0.02  # Adjust as needed for smooth movement

	# Simulate the movement (you can handle this in _process if needed)
	sprite.position += move_direction_left * move_speed * delta_time  # Move left half
	sprite.position += move_direction_right * move_speed * delta_time  # Move right half
