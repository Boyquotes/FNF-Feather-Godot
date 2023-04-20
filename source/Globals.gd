# Game Global variables, automatically loaded by autoload
# They serve the purpose of static variables in other languages
extends Node

### GENERAL ###
var game_volume:float = 0.5

### SONGS ###
var song_queue:Array[String] = ["bopeebo", "fresh", "dadbattle"]
var ignore_song_queue:bool = true # unless story mode or freeplay queue enabled
var queue_position:int = 0
