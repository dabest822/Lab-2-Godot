extends Node

var current_music: AudioStreamPlayer
var tween: Tween

@export var master_volume_db: float = 0

func play_music(stream: AudioStream, volume_db: float = 0, fade_duration: float = 1.0):
	print("Attempting to play music: ", stream.resource_path if stream else "None")
	if current_music:
		fade_out_current_music(fade_duration)
	
	current_music = AudioStreamPlayer.new()
	current_music.stream = stream
	current_music.bus = "Music"
	current_music.volume_db = -80  # Start silent
	add_child(current_music)
	current_music.play()
	print("Music started playing")
	
	tween = create_tween()
	tween.tween_property(current_music, "volume_db", volume_db + master_volume_db, fade_duration)

func fade_out_current_music(duration: float = 1.0):
	if current_music:
		tween = create_tween()
		tween.tween_property(current_music, "volume_db", -80, duration)
		tween.tween_callback(current_music.queue_free)
		current_music = null

func stop_music():
	if current_music:
		current_music.stop()
		current_music.queue_free()
		current_music = null

func set_master_volume(db: float):
	master_volume_db = db
	if current_music:
		current_music.volume_db = current_music.volume_db + master_volume_db

func adjust_volume(new_volume_db: float, fade_duration: float = 1.0):
	if current_music:
		tween = create_tween()
		tween.tween_property(current_music, "volume_db", new_volume_db + master_volume_db, fade_duration)
