extends Node2D

var cur_selection:int = 0
var cur_list:int = 0

var gameplay_options:Array[GameOption] = [
	GameOption.new("Downscroll", "downscroll", "Whether notes should scroll downards."),
	GameOption.new("Ghost Tapping", "ghost_tapping", "Whether pressing keys while having no notes to hit won't punish you."),
	GameOption.new("Centered Receptors", "center_notes", "Whether notes should be centered to the screen in gameplay."),
	GameOption.new("Framerate Cap", "framerate", "Define the limit for your FPS."),
	GameOption.new("VSync", "vsync", "Makes the game framerate match your monitor's refresh rate")
]

var visual_options:Array[GameOption] = [
	GameOption.new("Stage Darkness", "stage_darkness", "Define how much visible will the gameplay visuals be, useful if you find backgrounds and characters distracting.", [0, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]),
	GameOption.new("Reduced Motion", "reduced_motion", "Whether game objects should be less active, recommended if you have any sort of motion sickness."),
	GameOption.new("Flashing Lights", "flashing_lights", "Whether flashing effects should be enabled on menus and gameplay, disable if you are sensitive."),
	GameOption.new("Combo Stacking", "combo_stacking", "Whether the judgements and combo objects should stack on top of each other."),
	GameOption.new("Judgement Counter", "judgement_counter", "Whether to have a judgement counter, and in which position it should be", ["none", "left", "horizontal", "right"]),
	GameOption.new("Judgements on HUD", "hud_judgements", "Whether judgements and combo should be shown on the HUD instead of the world, making them easier to read."),
	GameOption.new("Improbable Offset", "fucked_up_sustains", "Breaks Sustain Note tail offsets.")
]

func _get_list_array():
	match _lists[cur_selection]:
		"Gameplay": return gameplay_options
		"Visuals": return visual_options
		_: return null

@onready var bg:Sprite2D = $Background
@onready var options_group:Node = $"Options Group"
@onready var description_box:Sprite2D = $"Description Box"
@onready var description_text:Label = $"Description Text"

var active_list:String = "Main"

var _current_options:Array[GameOption] = []
var _lists:Array[String] = ["Gameplay", "Visuals", "Controls"]

func _ready():
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
			Main.switch_scene("menus/MainMenu")
		else:
			active_list = "Main"
			reload_list(_lists)

func update_selection(new_selection:int = 0):
	if new_selection != 0: SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, options_group.get_child_count())
	update_list_items()
	
	var red = randi_range(100, 255)
	var blue = randi_range(60, 255)
	var green = randi_range(80, 255)
	
	get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
	.tween_property(bg, "modulate", Color8(red, blue, green), 0.35)

func update_state(new_selection:int = 0):
	if active_list == "Main":
		if _get_list_array() != null:
			active_list = _lists[cur_selection]
			reload_list(_get_list_array())
	else:
		var option = options_group.get_child(cur_selection)._raw_text
		if Settings.get_setting(option) is bool and new_selection == 0:
			Settings.set_setting(option, !Settings.get_setting(option))
			SoundGroup.play_sound(Paths.sound("scrollMenu"))
		else:
			if _current_options[cur_selection].choices.size() > 0:
				var cur_sel = _current_options[cur_selection]
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
	
	description_box.visible = active_list != "Main"
	description_text.visible = active_list != "Main"
	
	if active_list != "Main":
		description_text.text = _current_options[cur_selection].description

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
			label.force_X = 100
		else:
			label.screen_center("X")
		
		if options_list[i] is GameOption:
			label._raw_text = options_list[i].variable
		options_group.add_child(label)
	
	if options_list is Array[GameOption]:
		_current_options = options_list
	
	cur_selection = 0
	update_list_items()
