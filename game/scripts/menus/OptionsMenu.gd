extends Node2D

var cur_selection:int = 0
var cur_category:String = "main"

@onready var options_node:Node2D = $Options_Node
@onready var attached_objs:Node2D = $Attachments_Node
@onready var description_box:ColorRect = $Description_Box
@onready var description_text:Label = $Description_Box/Descrption_Text

var tools_options:Array[String] = ["XML Converter", "TXT Converter", "Chart Editor"]
@export var categories:Array[String] = ["Gameplay", "Behavior", "Visuals", "Controls", "Tools", "Exit"]

# messy thing but whatev, i can improve upon this later -BeastlyGabi
@export var gameplay_options:Array[GameOption] = []
@export var behavior_options:Array[GameOption] = []
@export var visual_options:Array[GameOption] = []

var _cur_options:Array[GameOption] = []

func _switch_category():
	match options_node.get_child(cur_selection).text.to_lower():
		"gameplay": reload_options_list(gameplay_options)
		"behavior": reload_options_list(behavior_options)
		"visuals": reload_options_list(visual_options)
		
		"controls":
			var controls_screen:PackedScene = load("res://game/scenes/menus/options/ControlsScreen.tscn")
			add_child(controls_screen.instantiate())
			get_tree().paused = true
		
		"tools": reload_options_list(tools_options)
		"xml converter": Game.switch_scene("XML Converter", false, "converters")
		"txt converter": Game.switch_scene("TXT Converter", false, "converters")
		"chart editor": Game.switch_scene("scenes/gameplay/editors/ChartEditor")
			
		_: _leave_scene()

func _leave_scene():
	Game.flicker_loops = 8
	if Game.options_to_gameplay:
		Game.switch_scene("scenes/gameplay/Gameplay")
		Game.options_to_gameplay = false
		SoundHelper.stop_music()
	else:
		Game.switch_scene("scenes/menus/MainMenu")
	Settings.save_settings()

func _ready():
	if SoundHelper.music.stream == null or not SoundHelper.music.playing:
		SoundHelper.play_music(Game.MENU_MUSIC)
	
	reload_options_list(categories)
	Game.flicker_loops = 2

var is_input_locked:bool = false

func _process(delta):
	if not cur_category == "main":
		options_node.get_child(cur_selection).force_X = 150
	
	for i in attached_objs.get_child_count():
		var obj = attached_objs.get_child(i)
		var opt = options_node.get_child(i)
		
		if not opt == null and not obj == null:
			if obj is AnimatedSprite2D:
				obj.position.x = opt.position.x - 80
			else:
				obj.position.x = opt.position.x + opt.width + 70
			obj.position.y = opt.position.y

	if not is_input_locked:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			var is_up:bool = Input.is_action_just_pressed("ui_up")
			update_selection(-1 if is_up else 1)
		
		if not cur_category == "main":
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				var is_left:bool = Input.is_action_just_pressed("ui_left")
				update_option(-1 if is_left else 1)
		
		if Input.is_action_just_pressed("ui_accept"):
			if cur_category == "main" or cur_category == "tools":
				var is_controls:bool = options_node.get_child(cur_selection).text.to_lower() == "controls"
				is_input_locked = true
				
				Game.flicker_loops = 2
				SoundHelper.play_sound("res://assets/audio/sfx/confirmMenu.ogg")
				await Game.do_object_flick(options_node.get_child(cur_selection), 0.08, true, func():
					if not is_controls:
						cur_category = options_node.get_child(cur_selection).text.to_lower()
					_switch_category()
				)
			else:
				update_option(0)
		
		
		if Input.is_action_just_pressed("ui_cancel"):
			if cur_category == "main":
				is_input_locked = true
				SoundHelper.play_sound("res://assets/audio/sfx/cancelMenu.ogg")
				_leave_scene()
			
			else:
				_cur_options = []
				cur_category = "main"
				Game.flicker_loops = 2
				reload_options_list(categories)

func update_option(new_selection:int = 0):
	if _cur_options[cur_selection].reference == null: return
	
	var option = _cur_options[cur_selection]
	var letter = options_node.get_child(cur_selection)
	
	if option.reference.length() < 1: return
	
	if option.value is bool and new_selection == 0:
		option.value = not option.value
		attached_objs.get_child(cur_selection).get_node("AnimationPlayer").play(str(option.value))
		SoundHelper.play_sound("res://assets/audio/sfx/scrollMenu.ogg")
	
	elif not new_selection == 0:
		if option.value is int or option.value is float:
			option.value = wrapf(option.value + new_selection * option.num_factor, option.num_min, option.num_max)
			attached_objs.get_child(cur_selection).text = "<" + option.display_mode % option.value + ">"
		
		elif option.value is String:
			var le_selection:int = wrapi(option.choices.find(option.value) + new_selection, 0, option.choices.size())
			option.value = option.choices[le_selection]
			
			attached_objs.get_child(cur_selection).text = "<" + option.value + ">"
		
		SoundHelper.play_sound("res://assets/audio/sfx/scrollMenu.ogg")

func update_selection(new_selection:int = 0):
	if _cur_options.size() > 1:
		var unselectable:bool = _cur_options[cur_selection].reference.length() < 1
		if unselectable:
			new_selection = -1 if new_selection < cur_selection else 1
		
	cur_selection = wrapi(cur_selection + new_selection, 0, options_node.get_child_count())
	
	if not new_selection == 0:
		SoundHelper.play_sound("res://assets/audio/sfx/scrollMenu.ogg")
	
	var bs:int = 0
	for item in options_node.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1.0 if item.id == 0 else 0.6
		if not cur_category == "main":
			item.force_X = 130
		bs += 1
		
	for i in attached_objs.get_child_count():
		if not attached_objs.get_child(i) == null:
			attached_objs.get_child(i).modulate.a = 1.0 if i == cur_selection else 0.6
	
	description_box.visible = false
	if not cur_category == "main" and not cur_category == "tools":
		description_box.visible = true
		description_text.text = _cur_options[cur_selection].description

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
		
		var added_attachment = false
		
		if cur_category == "main":
			new_item.screen_center("XY")
			new_item.position.y += (85 * i) - 180
		
		else:
			new_item.force_X = 130
			new_item.position.y += (35 * i)
			new_item.vertical_spacing = 120
			new_item.menu_item = true
		
			added_attachment = false
		
		if new_list[i] is GameOption:
			
			if new_list[i].reference.length() > 0:
				if new_list[i].value is bool:
					var checkbox:AnimatedSprite2D = $Attachment_Templetes/Checkbox.duplicate()
					checkbox.get_node("AnimationPlayer").play(str(new_list[i].value))
					checkbox.visible = true
					attached_objs.add_child(checkbox)
					added_attachment = true
				
				elif new_list[i].value is String or new_list[i].value is int or new_list[i].value is float:
					var selector:Alphabet = $Alphabet_Template.duplicate()
					selector.visible = true
					#selector.bold = false
					if new_list[i].value is String:
						selector.text = "<" + new_list[i].value + ">"
					else:
						selector.text = "<" + new_list[i].display_mode % new_list[i].value + ">"
					attached_objs.add_child(selector)
					added_attachment = true
			
			else:
				added_attachment = false
				new_item.force_X = 500
		
		if not added_attachment:
			attached_objs.add_child(Node2D.new())
		options_node.add_child(new_item)
	
	if new_list is Array[GameOption]:
		_cur_options = new_list

	is_input_locked = false
	cur_selection = 0
	update_selection()
