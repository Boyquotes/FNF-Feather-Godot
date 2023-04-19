extends BeatScene

func _ready(): pass
func _process(delta:float): pass

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey:
		if keyEvent.keycode == KEY_ENTER:
			Main.switch_scene("Gameplay")
