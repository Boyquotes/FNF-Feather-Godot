class_name Stage extends BeatScene

var  game:Variant

func _ready():
	game = get_tree().current_scene

func _process(delta:float): pass

func beatHit(beat:int): pass
func stepHit(step:int): pass
func sectHit(sect:int): pass
