extends TextureButton

# Exported variable to specify the scene path to return to the Title Screen
@export var title_screen_path: String = "res://Scenes/Title Screen.tscn"

func _ready():
	# Connect the pressed signal to return to the Title Screen scene
	if not is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_back_button_pressed():
	if title_screen_path != "":
		# Set the global variable to start in level select mode
		GlobalState.start_in_level_select = true

		# Change scene to the Title Screen
		get_tree().change_scene_to_file(title_screen_path)
	else:
		print("No scene path specified for the back button!")
