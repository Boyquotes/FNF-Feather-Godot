# Helper variables automatically loaded on startup
# They serve the purpose of static variables in other languages
@tool extends Node

### GENERAL ###
var game_volume:float = 0.5

var cols:Array[String] = ["purple", "blue", "green", "red"]
var dirs:Array[String] = ["left", "down", "up", "right"]

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

func float_to_minute(value:float): return int(value / 60)
func float_to_seconds(value:float): return fmod(value, 60)

func format_to_time(value:float):
	return "%02d:%02d" % [float_to_minute(value), float_to_seconds(value)]

func read_dir(folder:String):
	var files:PackedStringArray = []
	var dir_lib:DirAccess = DirAccess.open(folder)
	
	for fuck in dir_lib.get_files():
		while not files.has(fuck):
			files.append(fuck)
	
	return files
