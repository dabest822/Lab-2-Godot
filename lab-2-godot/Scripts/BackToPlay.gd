extends TextureButton

@export var title_music: AudioStream
@export var title_music_volume_db: float = -10

@onready var level_select_screen = get_parent()
@onready var play_screen = level_select_screen.get_parent().get_node("PlayScreen")

func _ready():
	if not is_connected("pressed", Callable(self, "_on_BackToPlay_pressed")):
		connect("pressed", Callable(self, "_on_BackToPlay_pressed"))

func _on_BackToPlay_pressed():
	print("Back to Play pressed")
	if title_music:
		print("Playing title music from back button")
		MusicManager.play_music(title_music, title_music_volume_db)
	else:
		print("No title music assigned to back button")
		MusicManager.stop_music()

	level_select_screen.hide()
	play_screen.show()
