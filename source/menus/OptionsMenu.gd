extends Node2D

var cur_selection:int = 0
var cur_list:int = 0

@onready var bg:Sprite2D = $Background
@export var options:Array[GameOption] = []

var options_group:Node
var list_name:Alphabet

var _lists:Array[String] = ["Gameplay", "Appearance", "Controls"]

func _ready():
	list_name = Alphabet.new(_lists[cur_list], true, 0, 40)
	list_name.screen_center("X")
	add_child(list_name)
	
	options_group = Node.new()
	add_child(options_group)
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_left"): update_list(-1)
	if Input.is_action_just_pressed("ui_right"): update_list(1)
	if Input.is_action_just_pressed("ui_accept"): pass
	if Input.is_action_just_pressed("ui_cancel"): Main.switch_scene("menus/MainMenu")

var bg_tween:Tween
func update_selection(new_selection:int = 0):
	if new_selection != 0: AudioHelper.play_sound("SCROLL_MENU")
	cur_selection = wrapi(cur_selection+new_selection, 0, options.size())
	update_list_items()

func update_list_items():
	var bs:int = 0
	for item in options_group.get_children():
		item.id = bs - cur_selection
		if item.id == 0: item.modulate.a = 1
		else: item.modulate.a = 0.7
		bs+=1

func update_list(new_list:int = 0):
	if new_list != 0: AudioHelper.play_sound("SCROLL_MENU")
	cur_list = wrapi(cur_list+new_list, 0, _lists.size())
	list_name.text = _lists[cur_list]
	list_name.screen_center("X")
	update_selection()

func reload_list():
	for i in options.size():
		var label:FNFTextLabel = FNFTextLabel.new()
		label.position = Vector2(500, 500)
		label.append_text(options[i].name)
		label.push_font(load(Paths.get_asset_path("data/fonts/vcr.ttf")), 32)
		label.id = i
		options_group.add_child(label)
