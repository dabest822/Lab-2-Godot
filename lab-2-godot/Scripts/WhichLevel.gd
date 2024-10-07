extends TextureButton

@export var scene_path: String
@export var level_music: AudioStream
@export var level_music_volume_db: float = -10  # Adjust this value as needed

func _ready():
	if not is_connected("pressed", Callable(self, "_on_button_pressed")):
		connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	if scene_path != "":
		GlobalState.set_difficulty_by_level(scene_path)
		if level_music:
			MusicManager.play_music(level_music, level_music_volume_db)
		get_tree().change_scene_to_file(scene_path)
	else:
		print("No scene path specified for this button!")
