# Game Global variables, automatically loaded by autoload
# They serve the purpose of static variables in other languages
extends Node

### GENERAL ###
var game_volume:float = 0.5

### SONGS ###
const default_diffs:Array[String] = ["easy", "normal", "hard"]
var song_queue:Array[String] = ["bopeebo", "fresh", "dadbattle"]
var difficulty_name:String = "normal"
var ignore_song_queue:bool = false # unless story mode or freeplay queue enabled
var queue_position:int = 0

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
