extends TextureButton

# Exported variable to specify the scene path for each button in the Inspector
@export var scene_path: String

func _ready():
	# Connect the pressed signal to load the specified scene
	if not is_connected("pressed", Callable(self, "_on_button_pressed")):
		connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		print("No scene path specified for this button!")
