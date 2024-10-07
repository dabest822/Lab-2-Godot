extends Node

@export var title_music: AudioStream
@export var title_music_volume_db: float = -10

func _ready():
	if title_music:
		print("Playing initial title music")
		MusicManager.play_music(title_music, title_music_volume_db)
	else:
		print("No title music assigned to initial screen")
