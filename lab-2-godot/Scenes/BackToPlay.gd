extends TextureButton

@onready var level_select_screen = get_parent()  # Reference to LevelSelectScreen (parent of Back button)
@onready var play_screen = level_select_screen.get_parent().get_node("PlayScreen")  # Reference to PlayScreen

func _ready():
	# Connect the pressed signal if not already connected
	if not is_connected("pressed", Callable(self, "_on_BackToPlay_pressed")):
		connect("pressed", Callable(self, "_on_BackToPlay_pressed"))

func _on_BackToPlay_pressed():
	# Hide the LevelSelectScreen and show the PlayScreen
	level_select_screen.hide()
	play_screen.show()
