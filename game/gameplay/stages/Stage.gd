class_name Stage extends BeatScene

var game:Variant

@export_group("Camera Settings")
@export var camera_zoom:float = 1.05
@export var camera_speed:float = 1
@export var camera_offset:Vector2 = Vector2.ZERO

func _ready():
	game = get_tree().current_scene

func _process(delta:float): pass

func beat_hit(beat:int): pass
func step_hit(step:int): pass
func sect_hit(sect:int): pass
