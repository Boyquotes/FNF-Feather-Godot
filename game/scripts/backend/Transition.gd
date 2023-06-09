extends CanvasLayer

@onready var rectangle:Sprite2D = $Black_Box

func _ready():
	if not is_inside_tree():
		return
	
	create_tween().set_ease(Tween.EASE_IN) \
	.tween_property(rectangle, "position:y", 1300.0, 0.90) \
	.finished.connect(queue_free)
