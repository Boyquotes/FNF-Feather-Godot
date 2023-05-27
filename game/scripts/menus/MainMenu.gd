extends BeatScene

var cur_selection:int = 0
var options:Array[String] = ["story mode", "freeplay", "options"]

@onready var magenta = $Magenta
@onready var buttons = $"Buttons"

func _ready():
	if SoundGroup.music.stream == null or not SoundGroup.music.playing:
		SoundGroup.play_music(Paths.music("freakyMenu"), 0.5, true)
	
	for i in buttons.get_child_count():
		if Main.seen_main_menu_intro:
			buttons.get_child(i).position.x = 648
		else:
			var cool_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART) \
			.tween_property(buttons.get_child(i), "position:x", 648, 0.5).set_delay(0.1 * i)
			
			if i == buttons.get_child_count() - 1:
				cool_tween.finished.connect(func():
					Main.seen_main_menu_intro = true
					can_move = true
				)

var can_move:bool = false if not Main.seen_main_menu_intro else true

func _process(_delta):
	for node in options:
		var anim:String = "basic"
		if node == options[cur_selection]:
			anim = "white"
		buttons.get_node(node).play(anim)
	
	if can_move:
		# if Input.is_action_just_pressed("pause"):
		#	Main.switch_scene("ModsMenu", "game/scenes/menus")
		if Input.is_action_just_pressed("ui_up"): update_selection(-1)
		if Input.is_action_just_pressed("ui_down"): update_selection(1)
		if Input.is_action_just_pressed("ui_accept"):
			SoundGroup.play_sound(Paths.sound("confirmMenu"))
			can_move = false
			#hide_buttons()
			flicker_objects()
			await(get_tree().create_timer(0.8).timeout)
			switch_cur_scene()

func update_selection(new_selection:int = 0):
	SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, options.size())

func switch_cur_scene():
	match options[cur_selection]:
		"freeplay": Main.switch_scene("FreeplayMenu", "game/scenes/menus")
		"options": Main.switch_scene("OptionsMenu", "game/scenes/menus")
		_:
			print("selected " + options[cur_selection])
			can_move = true

func flicker_objects():
	if !magenta.visible: magenta.visible = true
	magenta.play("flash")
	buttons.get_child(cur_selection).play("flash")

func hide_buttons():
	for node in options:
		var tween:Tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(buttons.get_node(node), "modulate:a", 0, 0.4)
