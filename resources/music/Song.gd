@tool extends Node

### SONG ###
var song_queue:Array[String] = ["test"]
var ignore_song_queue:bool = false # unless story mode or freeplay queue enabled
var queue_position:int = 0

### DIFFICULTY ###
const default_diffs:Array[String] = ["easy", "normal", "hard"]
var active_difficulties:Array[String] = default_diffs
var difficulty_name:String = "normal"

var song_saves:ConfigFile = ConfigFile.new()

func save_score(song:String, difficulty:String, score:int):
	var true_song:String = song + "-" + difficulty.to_lower()
	
	song_saves.load("user://scores.cfg")
	song_saves.set_value("Song Highscores", true_song, score)
	song_saves.save("user://scores.cfg")

func get_score(song:String, difficulty:String) -> int:
	var true_song:String = song + "-" + difficulty.to_lower()
	
	song_saves.load("user://scores.cfg")
	if song_saves.has_section_key("Song Highscores", true_song):
		return song_saves.get_value("Song Highscores", true_song)
	return 0
