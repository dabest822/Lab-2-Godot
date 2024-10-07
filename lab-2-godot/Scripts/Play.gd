extends TextureButton

@onready var play_screen = get_parent()  # Reference to PlayScreen (parent of Play button)
@onready var level_select_screen = play_screen.get_parent().get_node("LevelSelectScreen")  # Reference to LevelSelectScreen

func _ready():
	# Check the global state to determine which screen to show
	if GlobalState.start_in_level_select:
		show_level_select_screen()
		GlobalState.start_in_level_select = false  # Reset the flag after showing level select
	else:
		show_play_screen()

	# Connect the Play button pressed signal
	if not is_connected("pressed", Callable(self, "_on_Play_pressed")):
		connect("pressed", Callable(self, "_on_Play_pressed"))

func _on_Play_pressed():
	# Switch from PlayScreen to LevelSelectScreen
	show_level_select_screen()

func show_play_screen():
	# Show only the PlayScreen and hide the LevelSelectScreen
	play_screen.show()
	level_select_screen.hide()

func show_level_select_screen():
	# Show only the LevelSelectScreen and hide the PlayScreen
	level_select_screen.show()
	play_screen.hide()

	# Make sure all children of LevelSelectScreen are visible
	for child in level_select_screen.get_children():
		child.visible = true
