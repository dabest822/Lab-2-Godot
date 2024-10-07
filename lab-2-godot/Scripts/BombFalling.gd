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

			# Set the sword slash position to the mouse click, ensuring it doesn't follow the bomb
			current_sword_slash.global_position = click_position  # Set its global position to the mouse click
			current_sword_slash.rotation = randf() * TAU  # Set a random rotation between 0 and 2*PI (TAU is a full circle in radians)

			# Add the sword slash to the scene root (or an appropriate non-moving parent)
			get_tree().root.add_child(current_sword_slash)

			# Start the timer to queue the slash instance for deletion after 0.1 seconds
			sword_slash_timer.start(0.1)

func delete_sword_slash_after_delay():
	if current_sword_slash:
		current_sword_slash.queue_free()
		current_sword_slash = null

func _on_bomb_clicked(_viewport, event, _shape_idx):
	print("Input event on bomb area")
	if event.is_action_pressed("Click"):
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

		# Play the explosion sound
		if audio_player:
			audio_player.get_parent().remove_child(audio_player)  # Remove from the current parent
			get_tree().root.add_child(audio_player)  # Reparent it to the scene root to keep it alive
			audio_player.owner = get_tree().root
			audio_player.play()

		# Connect the animation finished signal only if not already connected
		if not explosion.is_connected("animation_finished", Callable(self, "_on_explosion_finished")):
			explosion.connect("animation_finished", Callable(self, "_on_explosion_finished"))

func _on_explosion_finished():
	print("Explosion animation finished")
	queue_free()  # Remove the bomb immediately after the explosion animation finishes
