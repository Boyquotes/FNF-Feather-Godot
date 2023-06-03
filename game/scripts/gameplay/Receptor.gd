class_name Receptor extends AnimatedSprite2D

var cpu_receptor:bool = false
var finished_anim:bool = false
var direction:int

func _ready():
	animation_finished.connect(func():
			finished_anim = true
	)


func _process(delta:float):
	if cpu_receptor:
		if last_anim.ends_with("confirm") and finished_anim:
			play_anim(Game.note_dirs[direction].to_lower() + " static", true)


var last_anim:String


func play_anim(anim_name:String, forced:bool = false, speed:float = 1.0, from_end:bool = false):
	if forced or not last_anim == anim_name or finished_anim:
		if forced:
			frame = 0
			get_node("AnimationPlayer").seek(0.0)
		
		last_anim = anim_name
		finished_anim = false
		get_node("AnimationPlayer").play(anim_name, -1, speed * Conductor.pitch_scale, from_end)
