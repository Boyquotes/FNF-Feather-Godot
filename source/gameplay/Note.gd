class_name Note extends Node

var direction:int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
var time:float = 0.0 # Time in Milliseconds
var type:String = "default" # Time in Chart

var sustain_len:float = 0.0 # Sustain Tail Scale in Chart
var strumLine:int = 0 # Strumline that the note follows (set in chart)

var can_be_hit:bool = false # If the player can hit this note
var was_good_hit:bool = false # If this note has already been hit
var too_late:bool = false # If the player took to long too hit a note

# Defines if the note is in input range
# Meaning that it can actually have a chance to be hit
var inInputRange:bool = false

var player_note:bool = false

var early_hitMult:float = 1
var late_hitMult:float = 1

func _init(time:float, direction:int, type:String = "default"):
	pass

func _ready():
	$arrow.visible = true
	pass

func _process(delta:float):
	if player_note: # change safeZone to MS Threshold later ig
		can_be_hit = (time > Conductor.song_position - (Conductor.safe_zone * early_hitMult)
					and time < Conductor.song_position - (Conductor.safe_zone * late_hitMult))
