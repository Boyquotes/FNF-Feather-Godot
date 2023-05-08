@tool extends Node

### SONGS ###
const default_diffs:Array[String] = ["easy", "normal", "hard"]
var song_queue:Array[String] = ["bopeebo", "fresh", "dadbattle"]
var difficulty_name:String = "normal"
var ignore_song_queue:bool = false # unless story mode or freeplay queue enabled
var queue_position:int = 0

### GAMEPLAY ###
var modifiers:Array[String] = []

func save_score(song:String, score:int):
	var cool_config:ConfigFile = ConfigFile.new()
	var score_loader:Error = cool_config.load("res://scores.cfg")
	if score_loader == OK: pass
