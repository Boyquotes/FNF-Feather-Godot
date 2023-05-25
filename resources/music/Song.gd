@tool extends Node

### SONG ###
var song_queue:Array[String] = ["test"]
var ignore_song_queue:bool = false # unless story mode or freeplay queue enabled
var queue_position:int = 0

### DIFFICULTY ###
const default_diffs:Array[String] = ["easy", "normal", "hard"]
var active_difficulties:Array[String] = default_diffs
var difficulty_name:String = "normal"

func save_score(song:String, score:int):
	var cool_config:ConfigFile = ConfigFile.new()
	var score_loader:Error = cool_config.load("res://scores.cfg")
	if score_loader == OK: pass
