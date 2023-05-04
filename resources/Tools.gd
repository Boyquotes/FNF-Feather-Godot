# Helper variables automatically loaded on startup
# They serve the purpose of static variables in other languages
@tool extends Node

### GENERAL ###
var game_volume:float = 0.5

const default_controls:Dictionary = {
	# UI Directions
	"ui_left": ["A", "LEFT"],
	"ui_down": ["S", "DOWN"],
	"ui_up": ["W", "UP"],
	"ui_right": ["D", "RIGHT"],
	# Notes Directions
	"note_left": ["D", "LEFT"],
	"note_down": ["F", "DOWN"],
	"note_up": ["J", "UP"],
	"note_right": ["K", "RIGHT"],
	# Actions
	"accept": ["Z", "ENTER"],
	"back": ["X", "ESCAPE"],
	"reset": ["R", null],
	"pause": ["ESCAPE", "ENTER"]
}

var user_controls:Dictionary = default_controls.duplicate()

func bind_to_fps(rate:float):
	return rate * (60 / Engine.get_frames_per_second())

func play_sound(sound:String):
	get_node("/root/SoundEffects").find_child(sound).play(0.0)

func get_sound_pos(sound:String):
	return get_node("/root/SoundEffects").find_child(sound).get_playback_position()

func center_to_obj(obj, base, axis:String):
	match axis.to_upper():
		"X": obj.position.x = (Main.GAME_SIZE.x - base.get_viewport_rect().size.x / 2) / 2
		"Y": obj.position.y = (Main.GAME_SIZE.y - base.get_viewport_rect().position.y) / 2
		"XY": obj.position = Vector2((Main.GAME_SIZE.x - base.get_viewport_rect().size.x) / 2,
			(Main.GAME_SIZE.y - base.get_viewport_rect().position.y) / 2)
