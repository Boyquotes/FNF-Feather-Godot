extends Node2D

func _ready():
	pass

func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ESCAPE: Main.switch_scene("Gameplay")
