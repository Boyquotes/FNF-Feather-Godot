extends CanvasLayer

@onready var black_rect:Sprite2D = $"Black Rectangle"

var out:bool = false

func _ready():
	if not is_inside_tree(): return
	
	if out: 
		black_rect.texture.fill_from.y = 1
		black_rect.texture.fill_to.y = 0
	
	create_tween().set_ease(Tween.EASE_OUT if out else Tween.EASE_IN) \
	.tween_property(black_rect, "position:y", 1000.0, 0.70) \
	.finished.connect(queue_free)
