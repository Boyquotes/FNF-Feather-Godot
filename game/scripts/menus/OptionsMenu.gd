extends Node2D

const CONTROLS_SCREEN = preload("res://game/scenes/subScenes/ControlsScreen.tscn")

var cur_selection:int = 0
var cur_list:int = 0

var gameplay_options:Array[GameOption] = [
	GameOption.new("Downscroll", "downscroll", "Whether notes should scroll downwards."),
	GameOption.new("Ghost Tapping", "ghost_tapping", "Whether pressing keys while having no notes to hit won't punish you."),
	GameOption.new("Centered Receptors", "center_notes", "Whether notes should be centered to the screen in gameplay."),
	GameOption.new("CPU Receptors", "cpu_notes", "Whether the CPU's Strumline and Notes should be visible during gameplay."),
	GameOption.new("Note Scroll Speed", "note_speed", "Define your note speed, zero means it will use the speed from the chart.", [0.0, 0.25, 0.5, 1.0, 1.25, 1.5, 2.0, 2.25, 2.5, 3.0, 3.25, 3.5, 4.0, 4.25, 4.5, 5.0]),
	GameOption.new("Framerate Cap", "framerate", "Define the limit for your FPS.", [0, 30, 60, 90, 120, 160, 240, 260, 320, 360, 380, 400]),
	GameOption.new("VSync", "vsync", "Makes the game framerate match your monitor's refresh rate"),
]

var visual_options:Array[GameOption] = [
	GameOption.new("Note Splashes", "note_splashes", "Whether to have splash effects pop when hitting \"Sick!\"s or notes that have them enabled."),
	GameOption.new("Millisecond Display", "show_ms", "Whether tho show a millisecond display when hitting notes."),
	GameOption.new("Reduced Motion", "reduced_motion", "Reduces bumping on cameras and visual elements, recommended for those who suffer with motion sickness or want the elements to be quieter."),
	#GameOption.new("Note Quantization", "beat_colored_notes", "Whether notes should change colors based on the song's beat and bpm."),
	GameOption.new("Opaque Sustain Notes", "opaque_sustains", "Whether sustains should be completely opaque instead of slightly transparent."),
	GameOption.new("Flashing Lights", "flashing_lights", "Whether flashing effects should be enabled on menus and gameplay, disable if you are sensitive."),
	GameOption.new("Combo Stacking", "combo_stacking", "Whether the judgements and combo objects should stack on top of each other."),
	GameOption.new("Judgement Counter", "judgement_counter", "Whether to have a judgement counter, and in which position it should be", ["none", "left", "horizontal", "right"]),
	GameOption.new("Judgements on HUD", "hud_judgements", "Whether judgements and combo should be shown on the HUD instead of the world, making them easier to read."),
]

func _get_list_array():
	match _lists[cur_selection]:
		"Gameplay": return gameplay_options
		"Visuals": return visual_options
		_: return null

@onready var bg:Sprite2D = $Background
@onready var bg_grad:Sprite2D = $Gradient
@onready var options_group:Node = $"Options Group"
@onready var description_text:Label = $"Description Text"

var active_list:String = "Main"

var _current_options:Array[GameOption] = []
var _lists:Array[String] = ["Gameplay", "Visuals", "Controls"]

func _ready():
	Main.change_rpc("OPTIONS MENU", "In the Menus")
	
	reload_list(_lists)
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_left"): update_state(-1)
	if Input.is_action_just_pressed("ui_right"): update_state(1)
	if Input.is_action_just_pressed("ui_accept"): update_state()
	if Input.is_action_just_pressed("ui_cancel"):
		if active_list == "Main":
			if Main.options_to_gameplay:
				SoundGroup.stop_music()
				Main.options_to_gameplay = false
				Main.switch_scene("gameplay/Gameplay")
			else: Main.switch_scene("menus/MainMenu")
		else:
			active_list = "Main"
			reload_list(_lists)

func update_selection(new_selection:int = 0):
	if new_selection != 0: SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, _lists.size() if active_list == "Main" else _current_options.size()	)
	update_list_items()
	
	var red = randi_range(100, 255)
	var blue = randi_range(60, 255)
	var green = randi_range(80, 255)
	
	get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
	.tween_property(bg, "modulate", Color8(red, blue, green), 0.35)
	
	get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
	.tween_property(bg_grad, "modulate", Color8(red, blue, green), 0.55)

func update_state(new_selection:int = 0):
	if active_list == "Main":
		if not _lists[cur_selection] == "Controls":
			active_list = _lists[cur_selection]
			if _get_list_array() != null:
				reload_list(_get_list_array())
		else:
			var controls_scene = CONTROLS_SCREEN.instantiate()
			get_tree().paused = true
			add_child(controls_scene)
	else:
		var _option = _current_options[cur_selection]
		if _option.value is bool and new_selection == 0:
			_option.value = !_option.value
			SoundGroup.play_sound(Paths.sound("scrollMenu"))
		else:
			if _option.choices.size() > 0:
				var cur_value = _option.value
				var new_value:int = 0
				
				new_value = wrapi(_option.choices.find(_option.value) + new_selection, 0, _option.choices.size())
				_option.value = _option.choices[new_value]
				print(_option.choices[new_value])
				
				SoundGroup.play_sound(Paths.sound("scrollMenu"))
		
		Settings.save_config()
		Settings.update_prefs()
	
	update_list_items()

func update_list_items():
	var bs:int = 0
	for item in options_group.get_children():
		item.id = bs - cur_selection
		
		item.modulate = Color.WHITE
		if item._raw_text != "":
			var option = item._raw_text
			if Settings.get_setting(option) is bool and Settings.get_setting(option) == true:
				item.modulate = Color.SPRING_GREEN
		
		item.modulate.a = 1 if item.id == 0 else 0.7
		bs+=1
	
	if active_list != "Main" and not _current_options[cur_selection].description == null:
		description_text.text = _current_options[cur_selection].description
	elif active_list == "Main":
		var le_desc:String = "..."
		match _lists[cur_selection]:
			"Gameplay": le_desc = "Adjust gameplay elements to fit your needs."
			"Visuals": le_desc = "Tweak your game's visuals to match your desired result."
			"Controls": le_desc = "Change your game controls to better suit your needs"
		description_text.text = le_desc

func reload_list(options_list):
	if options_group.get_child_count() > 0:
		for child in options_group.get_children():
			options_group.remove_child(child)
	
	for i in options_list.size():
		var label:Alphabet = $AlphabetTemp.duplicate()
		label.position = Vector2(0, 250 + (100 * i))
		label.text = options_list[i].name if options_list[i] is GameOption else options_list[i]
		label.id = i
		
		# hardcoded main category
		if active_list != "Main":
			label.menu_item = true
			label.vertical_spacing = 100
			label.force_X = 150
		
		if options_list[i] is GameOption:
			label._raw_text = options_list[i].variable
		options_group.add_child(label)
	
	if options_list is Array[GameOption]:
		_current_options = options_list
	
	var list_details:String = "In the Menus"
	match active_list:
		"Gameplay":
			list_details = "Tweaking Gameplay Features"
			$"Category Name".text = "Gameplay"
		"Visuals":
			list_details = "Customizing Visuals"
			$"Category Name".text = "Visuals"
		_:
			list_details = "In the Menus"
			$"Category Name".text = "Options Menu"
	$"Category Name".screen_center("X")
	
	if active_list == "Main":
		for letter in options_group.get_children():
			letter.screen_center("X")
	
	Main.change_rpc("OPTIONS MENU", list_details)
	
	cur_selection = 0
	update_list_items()
