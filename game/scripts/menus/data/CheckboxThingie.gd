extends CanvasLayer

@onready var box:AnimatedAttachedSprite2D = $Checkbox
@onready var anim:AnimationPlayer = $Checkbox/Animation

var finished_anim:bool = false

func _ready():
	anim.animation_finished.connect(func():
			finished_anim = true
	)

func _process(_delta:float):
	if not anim == null and anim.is_playing() and anim.animation == "true_pending" and finished_anim:
		play_anim("true", true)


var last_anim:String


func play_anim(anim_name:String, forced:bool = false, speed:float = 1.0, from_end:bool = false):
	if forced or not last_anim == anim_name or finished_anim:
		if forced:
			box.frame = 0
			anim.seek(0.0)
		
		last_anim = anim_name
		finished_anim = false
		anim.play(anim_name, speed, from_end)
