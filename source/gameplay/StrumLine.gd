class_name StrumLine extends Control

var cpu:bool = false

var strums:Array[AnimatedSprite2D] = []
var notes:Array[Note] = []

func new():
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	pass

func _process(_delta:float):
	if len(notes) > 0:
		for note in notes:
			if note == null: note.queue_free() # fucking like whatever.
			note.x = strums[note.direction].x
			note.y = strums[note.direction].y
	pass
