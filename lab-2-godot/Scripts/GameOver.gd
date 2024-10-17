extends Node2D

@onready var ninja_sprite = $Ninja
@onready var back_arrow = $BackArrow
@onready var game_over_music = $GameOverMusic
@onready var dojo_bg = $DojoBG
@onready var mountain_bg = $MountainBG
@onready var great_wave_bg = $GreatWaveBG

var animation_phase = 0
var start_position_x = 0.0
var start_position_y = 0.0
var target_position_x = 30.0
var target_position_y = -200.0
var ninja_max_height = 50.0
var t = 0.0
var jump_speed = 1400.0

func _ready():
	setup_background()
	setup_music()
	setup_signals()
	update_high_score()
	setup_ninja_animation()

func setup_background():
	match GlobalState.current_level:
		"res://Scenes/Level 1 (Dojo).tscn":
			dojo_bg.show()
		"res://Scenes/Level 2 (Mountain).tscn":
			mountain_bg.show()
		"res://Scenes/Level 3 (The Great Wave).tscn":
			great_wave_bg.show()
		_:
			print("Warning: Unknown level, no background set.")

func setup_music():
	if game_over_music:
		MusicManager.stop_music()
		game_over_music.play()
	else:
		print("Warning: Game over music not found!")

func setup_signals():
	if not back_arrow.is_connected("pressed", Callable(self, "_on_back_arrow_pressed")):
		back_arrow.connect("pressed", Callable(self, "_on_back_arrow_pressed"))
	if not ninja_sprite.is_connected("animation_finished", Callable(self, "_on_ninja_animation_finished")):
		ninja_sprite.connect("animation_finished", Callable(self, "_on_ninja_animation_finished"))

func update_high_score():
	GlobalState.update_high_score(GlobalState.current_level, GlobalState.score)

func setup_ninja_animation():
	start_position_x = ninja_sprite.position.x
	start_position_y = ninja_sprite.position.y

func _on_back_arrow_pressed():
	if ninja_sprite:
		animation_phase = 1
		ninja_sprite.flip_h = false
		ninja_sprite.play("Ninja")

func _on_ninja_animation_finished():
	if animation_phase == 1:
		animation_phase = 2
		ninja_sprite.flip_h = true
		ninja_sprite.play("Ninja2")
		set_process(true)
	elif animation_phase == 2:
		print("Ninja2 animation finished, returning to level select screen")
		GlobalState.update_high_score(GlobalState.current_level, GlobalState.score)
		get_tree().change_scene_to_file("res://Scenes/Title Screen.tscn")

func _process(delta):
	if animation_phase == 2:
		t += delta * jump_speed / 1000.0
		if t > 1.0:
			t = 1.0
		ninja_sprite.position.x = lerp(start_position_x, target_position_x, t)
		var height = -2.0 * (t - 0.5) * (t - 0.5) + 1.0
		ninja_sprite.position.y = lerp(start_position_y, target_position_y - ninja_max_height, height)
		if ninja_sprite.position.x <= target_position_x:
			ninja_sprite.position.x = target_position_x
			ninja_sprite.position.y = target_position_y
			set_process(false)
			_on_ninja_animation_finished()
