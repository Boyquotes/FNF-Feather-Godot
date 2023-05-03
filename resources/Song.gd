@tool extends Node

### SONGS ###
const default_diffs:Array[String] = ["easy", "normal", "hard"]
var song_queue:Array[String] = ["bopeebo", "fresh", "dadbattle"]
var difficulty_name:String = "normal"
var ignore_song_queue:bool = false # unless story mode or freeplay queue enabled
var queue_position:int = 0
