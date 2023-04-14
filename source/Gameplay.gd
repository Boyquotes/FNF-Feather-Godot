extends Node2D

var song : SongChart

@onready var inst : AudioStreamPlayer = $Music/Inst
@onready var vocals : AudioStreamPlayer = $Music/Vocals

# @onready var stage : AnimatedSprite2D = $Objects/Stage
@onready var player : AnimatedSprite2D = $Objects/Player
@onready var opponent : AnimatedSprite2D = $Objects/Opponent

var songName : String = "test"
var difficulty : String = "normal"

func _ready():
	song = SongChart.loadChart(songName, difficulty)
	
	inst.stream = load(Paths.songs(songName + "/Inst.ogg"))
	vocals.stream = load(Paths.songs(songName + "/Voices.ogg"))
	
	inst.play()
	vocals.play()

func _process(_delta : float):
	if inst != null and inst.playing:
		Conductor.songPosition = inst.get_playback_position() * 1000
	
	update_scoreText()
	update_healthBar()
	pass

func _input(keyEvent : InputEvent):
	if keyEvent is InputEventKey:
		var increase : int = 0
		if keyEvent.pressed:
			match keyEvent.keycode:
				KEY_D: player.play("BF NOTE LEFT")
				KEY_F: player.play("BF NOTE DOWN")
				KEY_J: player.play("BF NOTE UP")
				KEY_K: player.play("BF NOTE RIGHT")
				KEY_9: Main.switch_scene("tools/convert/XML Converter")
	pass

# Gameplay
var score : int = 0
var misses : int = 0
var health : float = 0
var rating : String = ""

const scoreSep : String = " ~ "

func update_scoreText():
	var tempText : String = "MISSES: " + str(misses)
	tempText += scoreSep + "SCORE: " + str(score)
	tempText += scoreSep + "ACCURACY: " + str(accuracy) + "%"
	if rating.length() > 0:
		tempText += ' [' + rating + ']'

	$"User Interface/Score Text".text = tempText

func update_healthBar():
	health = clamp(health, 0, 100)
	$"User Interface/Health Bar".value = health
	pass

# Accuracy Handling
var noteHits : int = 0
var segments : int = 0
var accuracy : float = 0.00
