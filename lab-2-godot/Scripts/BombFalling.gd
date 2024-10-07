extends Node2D

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 2.0

@onready var sprite = $FallingBombs
@onready var explosion = $Explosion
@onready var area = $Area2D
@onready var audio_player = $ExplodingSound  # Reference to the audio player node

var is_exploding = false

func _ready():
	print("Bomb initialized")
	sprite.play("Falling")
	explosion.hide()
	
	if not area:
		print("Error: Area2D not found!")
		return
	
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_bomb_clicked"))

func _process(delta):
	if not is_exploding:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)

func _on_bomb_clicked(_viewport, event, _shape_idx):
	print("Input event on bomb area")
	if event.is_action_pressed("Click"):
		print("Bomb clicked!")
		explode()

func _input(event):
	if event.is_action_pressed("Click"):
		print("Click action detected at: ", get_global_mouse_position())
		if area and _is_point_inside_area(get_global_mouse_position()):
			print("Click overlaps with bomb area")
			explode()

func _is_point_inside_area(point: Vector2) -> bool:
	var local_point = area.to_local(point)
	for child in area.get_children():
		if child is CollisionShape2D:
			var shape = child.shape
			if shape is CircleShape2D:
				if local_point.length() <= shape.radius:
					return true
			elif shape is RectangleShape2D:
				var half_extents = shape.extents
				if abs(local_point.x) <= half_extents.x and abs(local_point.y) <= half_extents.y:
					return true
			# Add more shape types if needed
	return false

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
