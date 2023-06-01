extends Node2D

var cur_selection:int = 0
var cur_category:String = "main"

@onready var options_node:Node = $Options_Node
@export var categories:Array[String] = ["Gameplay", "Visuals", "Controls", "Exit"]

func _select_option():
	if cur_category == "main":
		match categories[cur_selection]:
			_: Game.switch_scene("scenes/menus/MainMenu")

func _ready():
	reload_options_list(categories)
	Game.flicker_loops = 2


var is_input_locked:bool = false


func _process(delta):
	if not is_input_locked:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			var is_up:bool = Input.is_action_just_pressed("ui_up")
			update_selection(-1 if is_up else 1)
		
		if Input.is_action_just_pressed("ui_accept"):
			is_input_locked = true
			
			SoundHelper.play_sound("res://assets/sounds/confirmMenu.ogg")
			await Game.do_object_flick(options_node.get_child(cur_selection), 0.08, true, func():
				Game.flicker_loops = 8
				_select_option()
			)
			


func update_selection(new_selection:int = 0):
	cur_selection = wrapi(cur_selection + new_selection, 0, options_node.get_child_count())
	
	if not new_selection == 0:
		SoundHelper.play_sound("res://assets/sounds/scrollMenu.ogg")
	
	var bs:int = 0
	for item in options_node.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1 if item.id == 0 else 0.6
		bs += 1


func reload_options_list(new_list:Array[String]):
	for letter in options_node.get_children():
		options_node.remove_child(letter)
	
	for i in new_list.size():
		var new_item:Alphabet = $Alphabet_Template.duplicate()
		new_item.text = new_list[i]
		new_item.screen_center("XY")
		new_item.position.y += (85 * i) - 130
		new_item.id = i
		options_node.add_child(new_item)
	
	cur_selection = 0
	update_selection()
