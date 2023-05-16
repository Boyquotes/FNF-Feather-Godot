extends Node2D

var cur_selection:int = 0
var cur_list:int = 0

@onready var bg:Sprite2D = $Background
@export var options:Array[GameOption] = []
@onready var options_box:Sprite2D = $"Options Box"
@onready var options_group:Node = $"Options Group"
var list_name:Alphabet

var _lists:Array[String] = ["Gameplay", "Appearance", "Controls"]

func _ready():
	list_name = Alphabet.new(_lists[cur_list], true, 0, 40)
	list_name.screen_center("X")
	# add_child(list_name)
	
	reload_list()
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_left"): update_list(-1)
	if Input.is_action_just_pressed("ui_right"): update_list(1)
	if Input.is_action_just_pressed("ui_accept"): update_state()
	if Input.is_action_just_pressed("ui_cancel"): Main.switch_scene("menus/MainMenu")

var bg_tween:Tween
func update_selection(new_selection:int = 0):
	if new_selection != 0: SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, options.size())
	update_list_items()

func update_state():
	var option = options_group.get_child(cur_selection)._raw_text
	if Settings.get_setting(option) is bool:
		Settings.set_setting(option, !Settings.get_setting(option))
	
	# print(Settings.get_setting(option))
	SoundGroup.play_sound(Paths.sound("scrollMenu"))
	Settings.save_config()
	update_list_items()

func update_list_items():
	var bs:int = 0
	for item in options_group.get_children():
		item.id = bs - cur_selection
		
		item.modulate = Color.WHITE
		var option = item._raw_text
		if Settings.get_setting(option) is bool and Settings.get_setting(option) == true:
			item.modulate = Color.SPRING_GREEN
		
		item.modulate.a = 1 if item.id == 0 else 0.7
		bs+=1

func update_list(new_list:int = 0):
	if new_list != 0: SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_list = wrapi(cur_list+new_list, 0, _lists.size())
	list_name.text = _lists[cur_list]
	list_name.screen_center("X")
	update_selection()

func reload_list():
	for i in options.size():
		var y_pos:float = (75 * i) + options_box.position.y
		var label:Alphabet = Alphabet.new(options[i].name, true, 150, y_pos)
		label.menu_item = true
		label.disable_X = true
		label._raw_text = options[i].variable
		label.vertical_spacing = 80
		label.id_off.y = 0.18
		label.id = i
		options_group.add_child(label)
