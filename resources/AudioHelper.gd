extends Node

@onready var music:AudioStreamPlayer = $MUSIC_STREAM
var cur_sound:AudioStreamPlayer

func play_music(msc:String, at_volume:float = 1.0, looped:bool = false, start_time:float = 0.0):
	music.stream = load(msc)
	music.play(start_time)
	music.stream.loop = looped
	music.volume_db = at_volume

func play_sound(sound:String, start_time:float = 0.0):
	cur_sound = find_child(sound)
	cur_sound.play(start_time)

func stop_music():
	if music != null:
		music.stop()

func stop_cur_sound():
	if cur_sound != null:
		cur_sound.stop()

func get_music_time():
	return music.get_playback_position() if music != null else 0.0

func get_cur_sound_time():
	return cur_sound.get_playback_position() if cur_sound != null else 0.0
