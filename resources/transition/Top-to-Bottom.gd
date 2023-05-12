extends CanvasLayer

@onready var black_rect:Sprite2D = $"Black Rectangle"

var tween:Tween
var trans_out:bool = false

func _ready():
	tween = create_tween().set_ease(Tween.EASE_IN)
	if trans_out: 
		black_rect.texture.fill_from.y = 1
		black_rect.texture.fill_to.y = 0
	
	tween.tween_property(black_rect, "position:y", 1000, 0.6) \
	.finished.connect(queue_free)
