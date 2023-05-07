class_name Stage extends BeatScene

var game:Variant

func _ready():
	game = get_tree().current_scene

func _process(delta:float): pass

func beat_hit(beat:int): pass
func step_hit(step:int): pass
func sect_hit(sect:int): pass
