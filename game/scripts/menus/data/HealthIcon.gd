# ONLY REALLY USED FOR FREEPLAY BULLSHIT
class_name HealthIcon extends Sprite2D

var spr_tracker:Alphabet

func _process(delta:float):
	if not spr_tracker == null:
		position = Vector2(spr_tracker.position.x + spr_tracker.width + 50, spr_tracker.position.y + 15)
