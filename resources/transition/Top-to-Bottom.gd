extends CanvasLayer

@onready var black_rect:Sprite2D = $"Black Rectangle"

var tween:Tween

func _ready():
	tween = create_tween()
	tween.tween_property(black_rect, "position:y", 1000, 0.6) \
	.finished.connect(queue_free)
