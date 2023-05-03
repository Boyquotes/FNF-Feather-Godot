class_name Note extends CanvasGroup

@export_category("Note Data")
@export var direction:int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
@export var time:float = 0.0 # Time in Milliseconds
@export var type:String = "default" # Time in Chart
@export var strumLine:int = 0 # Strumline that the note follows (set in chart)
@export var sustain_len:float = 0.0 # Sustain Tail Scale in Chart

@export_category("Type Properties")
@export var ignore_note:bool = false
@export var forces_miss:bool = false
@export var early_hitMult:float = 1
@export var late_hitMult:float = 1

@export_category("Gameplay Values")
@export var can_be_hit:bool = false # If the player can hit this note
@export var was_good_hit:bool = false # If this note has already been hit
@export var too_late:bool = false # If the player took to long too hit a note

# Defines if the note is in input range
# Meaning that it can actually have a chance to be hit
@export var inInputRange:bool = false

var player_note:bool = false

@onready var arrow := $arrow

func _init(time:float, direction:int, type:String = "default"):
	super._init()
	self.time = time
	self.direction = direction
	self.type = type

func _ready():
	arrow = AnimatedSprite2D.new()
	arrow.sprite_frames = load(Paths.sprite_res("notes/default/default"))
	arrow.apply_scale(Vector2(0.7, 0.7))
	add_child(arrow)

func _process(delta:float):
	if player_note: # change safeZone to MS Threshold later ig
		can_be_hit = (time > Conductor.song_position - (Conductor.safe_zone * early_hitMult)
					and time < Conductor.song_position - (Conductor.safe_zone * late_hitMult))
