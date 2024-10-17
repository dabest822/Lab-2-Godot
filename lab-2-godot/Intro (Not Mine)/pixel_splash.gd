extends Control

@onready var intro_music = $AudioStreamPlayer  # Reference to the AudioStreamPlayer

@export var title_screen_path: String = "res://Scenes/Title Screen.tscn"  # Path to the Title Screen

# Play the "Intro" animation, then queue the "FadeOut" animation
func _ready():
	# Play the intro music if it exists
	if intro_music:
		intro_music.play()

	$AnimationPlayer.play("Intro")
	$AnimationPlayer.queue("FadeOut")

# This will be called when the "FadeOut" animation finishes.
# It will switch to the Title Screen and stop the music.
func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "FadeOut":  # Only switch when "FadeOut" animation is done
		print("Finished playing the engine splash, switching to Title Screen!")
		
		# Stop the intro music (optional: fade it out instead)
		if intro_music:
			intro_music.stop()
		
		# Switch to the Title Screen scene
		get_tree().change_scene_to_file(title_screen_path)
