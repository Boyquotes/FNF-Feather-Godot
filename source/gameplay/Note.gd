extends Resource

class_name Note

var direction : int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
var time : float = 0.0 # Time in Milliseconds
var type : String = "default" # Time in Chart

var sustain_len : float = 0.0 # Sustain Tail Scale in Chart
var strumLine : int = 0 # Strumline that the note follows (set in chart)

var canBeHit : bool = false # If the player can hit this note
var hasBeenHit : bool = false # If this note has already been hit
var tooLate : bool = false # If the player took to long too hit a note

# Defines if the note is in input range
# Meaning that it can actually have a chance to be hit
var inInputRange : bool = false

var playerNote : bool = false

var earlyMult : float = 1
var lateMult : float = 1

func _ready():
	pass

func _process(delta : float):
	if playerNote: # change safeZone to MS Threshold later ig
		canBeHit = (time > Conductor.songPosition - (Conductor.safeZone * earlyMult)
					and time < Conductor.songPosition - (Conductor.safeZone * lateMult))
