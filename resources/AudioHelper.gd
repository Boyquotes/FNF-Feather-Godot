extends Node

@onready var music:AudioStreamPlayer = $MUSIC_STREAM
var cur_sound:AudioStreamPlayer

func play_music(msc:String, start_time:float = 0.0, looped:bool = false):
	music.stream = load(Paths.music(msc))
	music.autoplay = looped
	music.play(start_time)

func play_sound(sound:String, start_time:float = 0.0):
	cur_sound = find_child(sound)
	cur_sound.play(start_time)

func stop_music(clear:bool = false):
	if music != null:
		music.stop()
		if clear:
			music.queue_free()

func stop_cur_sound(clear:bool = false):
	if cur_sound != null:
		cur_sound.stop()
		if clear:
			cur_sound.queue_free()

func get_music_time():
	return music.get_playback_position() if music != null else 0.0

func get_cur_sound_time():
	return cur_sound.get_playback_position() if cur_sound != null else 0.0
