class_name Stage extends BeatScene

var game:Variant

@export_group("Character Settings")
@export var player_position:Vector2 = Vector2(850, 250)
@export var opponent_position:Vector2 = Vector2(100, 250)
@export var crowd_position:Vector2 = Vector2(480, 250)

@export_group("Camera Settings")
@export var camera_zoom:float = 1.05
@export var camera_speed:float = 1.0
@export var player_camera:Vector2 = Vector2.ZERO
@export var opponent_camera:Vector2 = Vector2.ZERO
@export var crowd_camera:Vector2 = Vector2.ZERO

func _ready():
	game = get_tree().current_scene

func _process(delta:float): pass

func beat_hit(beat:int): pass
func step_hit(step:int): pass
func sect_hit(sect:int): pass
