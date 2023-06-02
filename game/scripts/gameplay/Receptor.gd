class_name Receptor extends AnimatedSprite2D

var cpu_receptor:bool = false
var finished_anim:bool = false

func _ready():
	animation_finished.connect(func():
			finished_anim = true
	)


func _process(delta:float):
	if cpu_receptor:
		if finished_anim and animation.ends_with("confirm"):
			play_anim("arrow" + name.to_upper(), true)


var last_anim:String


func play_anim(anim_name:String, forced:bool = false, speed:float = 1.0, from_end:bool = false):
	if forced or not last_anim == anim_name or finished_anim:
		if forced: frame = 0
		last_anim = anim_name
		finished_anim = false
		play(anim_name, speed * Conductor.pitch_scale, from_end)
