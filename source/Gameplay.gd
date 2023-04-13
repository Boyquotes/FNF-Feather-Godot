extends Node2D

var noteList : Array = []
var eventList : Array = []

func _ready():
	Conductor.startSong("test", "normal")
	# pass

func _process(_delta : float):
	update_scoreText()
	update_healthBar()
	pass

func _input(keyEvent : InputEvent):
	if keyEvent is InputEventKey:
		var increase : int = 0
		if keyEvent.pressed:
			match keyEvent.keycode:
				KEY_D: increase = 10;
				KEY_K: increase = -10;
				KEY_0: increase = 0
				KEY_9: Main.switch_scene("tools/convert/XML Converter")
					
		if increase != 0:
			health += increase
			increase = 0
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
