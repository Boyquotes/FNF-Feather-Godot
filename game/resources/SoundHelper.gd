extends Node2D

@onready var music:AudioStreamPlayer = $MUSIC_STREAM
@onready var sound:AudioStreamPlayer = $AUDIO_STREAM

var music_file:String

func play_music(msc:String, at_volume:float = 1.0, looped:bool = true, start_time:float = 0.0):
	music.stream = load(msc)
	music.play(start_time)
	music.stream.loop = looped
	music.volume_db = 1 * at_volume
	music_file = msc

func play_sound(snd:String, start_time:float = 0.0, pitch_scale:float = 1.0):
	sound.stream = load(snd)
	sound.pitch_scale = pitch_scale
	sound.play(start_time)

func stop_music():
	if music != null:
		music.stop()

func stop_sound():
	if sound != null:
		sound.stop()

func get_music_time() -> float:
	return music.get_playback_position() if music != null else 0.0

func get_sound_time() -> float:
	return sound.get_playback_position() if sound != null else 0.0

func get_sound_length() -> float:
	return sound.stream.get_length() if sound != null else 0.0

func is_music_playing() -> bool:
	if not music.stream == null and music.playing:
		return true
	return false
		
