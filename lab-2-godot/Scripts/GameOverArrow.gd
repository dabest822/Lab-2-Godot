extends TextureButton

# Declare the custom signal
signal back_arrow_pressed

func _ready():
	# Ensure the pressed signal is connected to emit our custom signal
	if not is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_back_button_pressed():
	# Emit the custom signal
	emit_signal("back_arrow_pressed")
