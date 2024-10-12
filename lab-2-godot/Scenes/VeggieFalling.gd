extends Node2D

@onready var sprite = $FallingVeggies  # Use for the veggie sprite
@onready var audio_player = $VeggieCutSound  # Reference to the audio player node
@onready var area = $Area2D  # Reference to Area2D for collision detection

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0  # Speed for rotation while falling
@onready var veggie_types = ["BellPepper", "Broccoli", "Cabbage", "Carrot", "Cauliflower", "Corn", "Eggplant", "HotPepper", "Leek", "Lettuce", "Mushroom", "Onion", "Potato", "Pumpkin", "Tomato"]

var is_cut = false

func _ready():
	# Randomly pick a veggie animation on spawn
	var random_veggie = veggie_types[randi() % veggie_types.size()]
	sprite.play(random_veggie)  # No animation, but this will set the correct frame
	sprite.frame = 0  # Ensure we use the first frame (since it is a static image)
	print("Veggie initialized: ", random_veggie)
	
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

func _process(delta):
	if not is_cut:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)  # Rotate veggie as it falls

func _on_veggie_clicked(_viewport, event, _shapeidx):
	if event.is_action_pressed("Click"):
		print("Veggie clicked!")
		cut()  # For now, just remove the veggie

func cut():
	if not is_cut:
		is_cut = true
		sprite.hide()
		print("Veggie cut and removed!")

		# Play the cut sound
		if audio_player:
			audio_player.play()

		# Remove the veggie from the scene
		queue_free()
