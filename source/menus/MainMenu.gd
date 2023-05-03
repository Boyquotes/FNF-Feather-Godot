extends BeatScene

var cur_selection:int = 0
var options:Array[String] = ["story mode", "freeplay", "credits", "options"]
@onready var buttons = $"Buttons"

func _process(delta):
	for node in options:
		var anim:String = "basic"
		if node == options[cur_selection]:
			anim = "white"
		buttons.get_node(node).play(anim)
			

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_UP: update_selection(-1)
			KEY_DOWN: update_selection(1)
			KEY_ENTER: switch_cur_scene()
			

func update_selection(new_selection:int = 0):
	cur_selection = clampi(cur_selection + new_selection, 0, options.size() -1)
	$scroll_sound.play(0.0)

func switch_cur_scene():
	match options[cur_selection]:
		"freeplay": Main.switch_scene("menus/FreeplayMenu")
		"credits": Main.switch_scene("menus/CreditsMenu")
		_: Main.switch_scene("Gameplay")
