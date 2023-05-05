extends Node2D

@onready var black_rect:Sprite2D = $"Black Rectangle"

var tween:Tween

func _ready():
	tween = create_tween()

func _process(delta):
	tween.tween_property(black_rect, "position:y", 5, 1.0)
