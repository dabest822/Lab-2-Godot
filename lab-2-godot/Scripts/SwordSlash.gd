extends Sprite2D

@onready var timer = $SwordSlashTimer

var is_active = false

func _ready():
	hide()  # Hide the slash initially
	if timer:
		timer.connect("timeout", Callable(self, "_on_slash_timer_timeout"))
	else:
		push_error("SwordSlashTimer not found!")

func show_slash(position: Vector2):
	global_position = position
	rotation = randf_range(0, 2 * PI)
	show()
	is_active = true
	if timer:
		timer.start()
	else:
		push_warning("Timer not available, slash won't disappear automatically")

func _on_slash_timer_timeout():
	hide()
	is_active = false
	print("Slash hidden")
