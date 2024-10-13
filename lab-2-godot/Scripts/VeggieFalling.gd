extends Node2D

@onready var sprite = $FallingVeggies
@onready var audio_player = $VeggieCutSound
@onready var area = $Area2D

@export var fall_speed: float = 250.0
@export var rotation_speed: float = 1.2

var is_cut = false
var velocity_left = Vector2()
var velocity_right = Vector2()

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

var selected_index = 0

func _ready():
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_veggie_clicked"))

	for left in cut_left_nodes:
		left.visible = false
	for right in cut_right_nodes:
		right.visible = false

	selected_index = randi_range(0, 4)
	update_sprite_to_match_veggie(selected_index)

func update_sprite_to_match_veggie(index):
	var sprite_frames = load("res://Animations/VeggiesG%d.tres" % (index + 1)) as SpriteFrames
	if sprite_frames != null:
		sprite.frames = sprite_frames
		for i in range(5):
			cut_left_nodes[i].frames = sprite_frames
			cut_right_nodes[i].frames = sprite_frames
		print("Veggie type set to:", index + 1)

func _process(delta):
	if not is_cut:
		position.y += fall_speed * delta
		sprite.rotate(rotation_speed * delta)
	else:
		cut_left_nodes[selected_index].position += velocity_left * delta
		cut_right_nodes[selected_index].position += velocity_right * delta
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
			audio_player.play()

		sync_cut_pieces_with_main_sprite()
		sprite.hide()
		cut_left_nodes[selected_index].visible = true
		cut_right_nodes[selected_index].visible = true
		move_cut_halves()

		var timer = Timer.new()
		timer.wait_time = 2.0
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_timeout"))
		timer.start()

func sync_cut_pieces_with_main_sprite():
	var current_animation = sprite.animation
	var current_frame = sprite.frame
	cut_left_nodes[selected_index].animation = current_animation
	cut_right_nodes[selected_index].animation = current_animation
	cut_left_nodes[selected_index].frame = current_frame
	cut_right_nodes[selected_index].frame = current_frame
	cut_left_nodes[selected_index].rotation = sprite.rotation
	cut_right_nodes[selected_index].rotation = sprite.rotation
	print("Synced cut pieces. Animation:", current_animation, "Frame:", current_frame)

func move_cut_halves():
	var move_direction_left = Vector2(-0.5, 1.0)
	var move_direction_right = Vector2(0.5, 1.0)
	var move_speed = fall_speed * 1.0
	velocity_left = move_direction_left * move_speed
	velocity_right = move_direction_right * move_speed

func _on_timeout():
	queue_free()
