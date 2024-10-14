extends Node2D

@onready var ninja_sprite = $Ninja
@onready var back_arrow = $BackArrow
@onready var game_over_music = $GameOverMusic  # Reference to the game over music player
@onready var dojo_bg = $DojoBG
@onready var mountain_bg = $MountainBG
@onready var great_wave_bg = $GreatWaveBG

# Variables to handle animation and movement
var animation_phase = 0
var start_position_x = 0.0
var start_position_y = 0.0
var target_position_x = 30.0  # New target position for x (top-left corner)
var target_position_y = -200.0  # New target position for y (top-left corner)
var ninja_max_height = 50.0  # Adjust height of the jump
var t = 0.0  # Time factor for interpolation
var jump_speed = 1400.0  # Speed for the diagonal jump

func _ready():
	# Initial positions
	start_position_x = ninja_sprite.position.x
	start_position_y = ninja_sprite.position.y

	# Set the target position to match the top-left corner (around 30, 31)
	target_position_x = 30.0  # Fixed value for x
	target_position_y = -200.0  # Fixed value for y

	# Play game over music and stop the level music
	if game_over_music:
		MusicManager.stop_music()  # Stop the level music
		game_over_music.play()
	else:
		print("Warning: Game over music not found!")

	# Set up the correct background based on the current level
	match GlobalState.current_level:
		"Dojo":
			dojo_bg.show()
		"Mountain":
			mountain_bg.show()
		"GreatWave":
			great_wave_bg.show()
		_:
			print("Warning: Unknown level, no background set.")

	# Connect the back arrow button to trigger the jump and slash animation
	if not back_arrow.is_connected("pressed", Callable(self, "_on_back_arrow_pressed")):
		back_arrow.connect("pressed", Callable(self, "_on_back_arrow_pressed"))

	# Connect the animation_finished signal from the Ninja sprite
	if not ninja_sprite.is_connected("animation_finished", Callable(self, "_on_ninja_animation_finished")):
		ninja_sprite.connect("animation_finished", Callable(self, "_on_ninja_animation_finished"))

func _on_back_arrow_pressed():
	if ninja_sprite:
		animation_phase = 1  # Start with the first animation phase
		ninja_sprite.flip_h = false  # Don't flip for the "Ninja" animation
		ninja_sprite.play("Ninja")  # Play the first animation

func _on_ninja_animation_finished():
	if animation_phase == 1:
		# Move to the next phase (jump and slash)
		animation_phase = 2
		ninja_sprite.flip_h = true  # Flip for the "Ninja2" animation
		ninja_sprite.play("Ninja2")  # Play the second animation (jump and slash)
		set_process(true)  # Start processing the diagonal jump
	elif animation_phase == 2:
		print("Ninja2 animation finished, switching to title screen")
		# Switch to the title screen after the second animation finishes
		get_tree().change_scene_to_file("res://Scenes/Title Screen.tscn")

func _process(delta):
	# Only process the jump movement during the "Ninja2" animation phase
	if animation_phase == 2:
		# Increase the time factor 't' for controlling the curve movement
		t += delta * jump_speed / 1000.0  # Adjust factor based on speed
	
		# Clamp 't' to not exceed 1.0 (end of the jump)
		if t > 1.0:
			t = 1.0
	
		# Linear interpolation for the x-axis movement
		ninja_sprite.position.x = lerp(start_position_x, target_position_x, t)
	
		# Parabolic interpolation for the y-axis movement (smooth jump)
		var height = -2.0 * (t - 0.5) * (t - 0.5) + 1.0  # Parabolic motion (-4x^2 + 1)
		ninja_sprite.position.y = lerp(start_position_y, target_position_y - ninja_max_height, height)

		# When the ninja reaches the button position, clamp and stop the movement
		if ninja_sprite.position.x <= target_position_x:
			ninja_sprite.position.x = target_position_x
			ninja_sprite.position.y = target_position_y
			set_process(false)  # Stop further processing
			_on_ninja_animation_finished()  # Trigger the next phase (switch scene)
