extends Node2D

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0
@export var sword_slash_scene: PackedScene  # Drag and drop your SwordSlash.tscn here in the editor

@onready var sprite = $FallingBombs
@onready var explosion = $Explosion
@onready var area = $Area2D
@onready var audio_player = $ExplodingSound  # Reference to the audio player node
@onready var sword_slash_timer = $SwordSlashTimer  # Reference to the Timer node

var is_exploding = false
var current_sword_slash: Node2D = null  # Reference to the current sword slash instance
var has_emitted_bomb_hit: bool = false  # To ensure the bomb_hit signal is emitted only once

signal bomb_hit

func _ready():
	print("Bomb initialized")
	sprite.play("Falling")
	explosion.hide()

	if not area:
		print("Error: Area2D not found!")
		return

	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_bomb_clicked"))

	# Connect the Timer's timeout signal to the delete function
	sword_slash_timer.connect("timeout", Callable(self, "delete_sword_slash_after_delay"))

func _process(delta):
	if not is_exploding:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)

		# Check if bomb has moved beyond the bottom of the screen
		if position.y > get_viewport().size.y + 50:
			# Bomb falls off the screen, remove it without emitting the bomb hit signal
			print("Bomb has fallen off the screen. Removing bomb.")
			queue_free()

func _input(event):
	if event.is_action_pressed("Click"):
		var click_position = get_global_mouse_position()
		print("Click action detected at: ", click_position)

		# Remove the existing sword slash before creating a new one
		if current_sword_slash:
			current_sword_slash.queue_free()
			current_sword_slash = null

		# Create the sword slash effect at the mouse position
		if sword_slash_scene:
			current_sword_slash = sword_slash_scene.instantiate()  # Instantiate the sword slash

			# Set the sword slash position to the exact mouse click
			current_sword_slash.global_position = click_position
			current_sword_slash.rotation = randf() * TAU  # Set a random rotation between 0 and 2*PI (TAU is a full circle in radians)

			# Add the sword slash to the scene root so it appears exactly where needed
			get_tree().root.add_child(current_sword_slash)

			# Start the timer to queue the slash instance for deletion after 0.1 seconds
			sword_slash_timer.start(0.1)

func delete_sword_slash_after_delay():
	if current_sword_slash:
		current_sword_slash.queue_free()
		current_sword_slash = null

func _on_bomb_clicked(_viewport, event, _shapeidx):
	if not is_exploding and event.is_action_pressed("Click"):
		print("Bomb clicked!")
		explode()

func explode():
	print("Explode function called")
	if not is_exploding:
		is_exploding = true
		sprite.hide()
		explosion.show()
		print("Playing explosion animation")
		explosion.play("Explode")  # Make sure your animation is named "Explode"

		# Emit the signal when a bomb is hit by player action
		if not has_emitted_bomb_hit:
			emit_signal("bomb_hit")
			has_emitted_bomb_hit = true

		# Play the explosion sound
		if audio_player:
			audio_player.play()  # Play the sound normally

		# Connect the animation finished signal only if not already connected
		if not explosion.is_connected("animation_finished", Callable(self, "_on_explosion_finished")):
			explosion.connect("animation_finished", Callable(self, "_on_explosion_finished"))

func _on_explosion_finished():
	print("Explosion animation finished")
	explosion.hide()  # Hide the explosion animation properly
	# Only queue free after the audio player finishes the sound
	if audio_player and audio_player.is_playing():
		audio_player.connect("finished", Callable(self, "_on_audio_finished"))
	else:
		queue_free()

func _on_audio_finished():
	print("Explosion sound finished, removing bomb")
	queue_free()
