extends Node2D

var cur_selection:int = 0
var cur_category:String = "main"

@onready var options_node:Node = $Options_Node
@onready var attached_objs:Node = $Attachments_Node

@export var categories:Array[String] = ["Gameplay", "Visuals", "Controls", "Exit"]
@export var option_test_unit:Array[GameOption] = []

func _select_option():
	if cur_category == "main":
		match options_node.get_child(cur_selection).text.to_lower():
			_:
				if Game.options_to_gameplay:
					Game.switch_scene("scenes/gameplay/Gameplay")
					Game.options_to_gameplay = false
					SoundHelper.stop_music()
				else:
					Game.switch_scene("scenes/menus/MainMenu")

func _ready():
	if SoundHelper.music.stream == null or not SoundHelper.music.playing:
		SoundHelper.play_music(Game.MENU_MUSIC)
	
	reload_options_list(categories)
	Game.flicker_loops = 2


var is_input_locked:bool = false


func _process(delta):
	for i in attached_objs.get_child_count():
		var obj = attached_objs.get_child(i)
		var opt = options_node.get_child(i)
		obj.position.x = opt.position.x + opt.width + 70
		obj.position.y = opt.position.y

	if not is_input_locked:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			var is_up:bool = Input.is_action_just_pressed("ui_up")
			update_selection(-1 if is_up else 1)
		
		if Input.is_action_just_pressed("ui_accept"):
			if cur_category == "main":
				is_input_locked = true
				
				SoundHelper.play_sound("res://assets/sounds/confirmMenu.ogg")
				await Game.do_object_flick(options_node.get_child(cur_selection), 0.08, true, func():
					Game.flicker_loops = 8
					
					if cur_category == "main" and not options_node.get_child(cur_selection).text.to_lower() == "exit":
						cur_category = options_node.get_child(cur_selection).text.to_lower()
						reload_options_list(option_test_unit)
					
					_select_option()
				)
			else:
				var option = option_test_unit[cur_selection]
				var letter = options_node.get_child(cur_selection)
				
				if option.value is bool:
					option.value = not option.value
					attached_objs.get_child(cur_selection).get_node("AnimationPlayer").play(str(option.value))
		
		
		if Input.is_action_just_pressed("ui_cancel"):
			if cur_category == "main":
				is_input_locked = true
				SoundHelper.play_sound("res://assets/sounds/cancelMenu.ogg")
				if Game.options_to_gameplay:
					Game.switch_scene("scenes/gameplay/Gameplay")
					Game.options_to_gameplay = false
					SoundHelper.stop_music()
				else:
					Game.switch_scene("scenes/menus/MainMenu")
			
			else:
				cur_category = "main"
				Game.flicker_loops = 2
				reload_options_list(categories)

func update_selection(new_selection:int = 0):
	cur_selection = wrapi(cur_selection + new_selection, 0, options_node.get_child_count())
	
	if not new_selection == 0:
		SoundHelper.play_sound("res://assets/sounds/scrollMenu.ogg")
	
	var bs:int = 0
	for item in options_node.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1.0 if item.id == 0 else 0.6
		bs += 1
		
	for i in attached_objs.get_child_count():
		attached_objs.get_child(i).modulate.a = 1.0 if i == cur_selection else 0.6


func reload_options_list(new_list:Array):
	while options_node.get_child_count() > 0: #doing a while loop to prevent queue_free messing with the loop
		var opt = options_node.get_child(0)
		opt.queue_free()
		options_node.remove_child(opt)
		
	while attached_objs.get_child_count() > 0:
		var obj = attached_objs.get_child(0)
		obj.queue_free()
		attached_objs.remove_child(obj)
	
	for i in new_list.size():
		
		var new_item:Alphabet = $Alphabet_Template.duplicate()
		new_item.text = new_list[i].option if new_list[i] is GameOption else new_list[i]
		new_item.visible = true
		new_item.id = i
		
		var added_attachment = true
		
		if cur_category == "main":
			new_item.screen_center("XY")
			new_item.position.y += (85 * i) - 130
		
		else:
			new_item.force_X = 130
			new_item.position.y += (35 * i)
			new_item.vertical_spacing = 110
			new_item.id_off.y = 0.10
			new_item.menu_item = true
		
			added_attachment = false
		
		if new_list[i] is GameOption:
			var checkbox:AnimatedSprite2D = $Attachment_Templetes/Checkbox.duplicate()
			checkbox.get_node("AnimationPlayer").play(str(new_list[i].value))
			checkbox.visible = true
			attached_objs.add_child(checkbox)
			added_attachment = true
			
		if !added_attachment:
			attached_objs.add_child(Node.new())
		options_node.add_child(new_item)

	is_input_locked = false
	cur_selection = 0
	update_selection()
