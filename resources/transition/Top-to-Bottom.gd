extends CanvasLayer

@onready var black_rect:Sprite2D = $"Black Rectangle"

func play(out:bool):
	if out: 
		black_rect.texture.fill_from.y = 1
		black_rect.texture.fill_to.y = 0
	
	create_tween().set_ease(Tween.EASE_OUT if out else Tween.EASE_IN) \
	.tween_property(black_rect, "position:y", 1000, 0.6) # \
	# .finished.connect(queue_free)
