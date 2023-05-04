extends BeatScene

var cur_selection:int = 0
var options:Array[String] = ["story mode", "freeplay", "credits", "options"]
@onready var buttons = $"Buttons"

func _process(_delta):
	for node in options:
		var anim:String = "basic"
		if node == options[cur_selection]:
			anim = "white"
		buttons.get_node(node).play(anim)
	
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_accept"):
		Tools.play_sound("CONFIRM_MENU")
		await(get_tree().create_timer(0.5).timeout)
		switch_cur_scene()
	

func update_selection(new_selection:int = 0):
	Tools.play_sound("SCROLL_MENU")
	cur_selection = clampi(cur_selection+new_selection, 0, options.size() -1)

func switch_cur_scene():
	match options[cur_selection]:
		"freeplay": Main.switch_scene("menus/FreeplayMenu")
		"credits": Main.switch_scene("menus/CreditsMenu")
		_: Main.switch_scene("Gameplay")
	
	
