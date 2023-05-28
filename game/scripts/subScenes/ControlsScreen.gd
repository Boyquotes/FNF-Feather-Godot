extends Node2D

func _ready():
	var cool = $AlphabetTemp.duplicate()
	cool.text = "COOL"
	add_child(cool)

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().paused = false
		queue_free()
