extends CanvasLayer

@export var options:Array[String] = ["Resume", "Restart Song", "Change Options", "Exit to menu"]
@onready var bg:ColorRect = $Background
@onready var game = $"../"

@onready var song_txt:Label = $"Song Info"
@onready var diff_txt:Label = $"Diff Info"
@onready var time_txt:Label = $"Time Info"

var active_list:Array[String] = []
var difficulties:Array[String] = []

var finished_tween:bool = false
var cur_selection:int = 0
var pause_group:Node
var time_label:Alphabet

func _ready():
	SoundGroup.play_music(Paths.music("breakfast"), -30, true)
	SoundGroup.music.seek(randi_range(0, SoundGroup.music.stream.get_length() / 2.0))
	
	bg.color.a = 0
	
	song_txt.text = Song.song_name
	diff_txt.text = Song.difficulty_name.to_upper()
	time_txt.text = Tools.format_to_time(game.inst.get_playback_position()) \
	+ " / " + Tools.format_to_time(game.inst.stream.get_length()) if not game.inst == null else "00:00 / 00:00"
	
	var tweener:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(bg, "color:a", 0.6, 0.40)
	
	for info in [song_txt, diff_txt, time_txt]:
		info.modulate.a = 0.0
		info.size.x = 0
		info.position.x = Main.SCREEN["width"] - (info.size.x + 6)
		tweener.tween_property(info, "modulate:a", 1, 0.40)
	
	#if game.play_mode != game.GameMode.STORY:
	#	options.insert(3, "Jump Time to")
	#	
	#	time_label = $AlphabetTemp.duplicate()
	#	time_label.text = get_formatted_time(game.inst.get_playback_position())
	#	time_label.visible = false
	#	add_child(time_label)
	
	if Song.difficulties.size() > 1:
		options.insert(2, "Change Difficulty")
		for i in Song.difficulties:
			difficulties.append(i)
		difficulties.append("back")
	
	pause_group = Node.new()
	add_child(pause_group)
	
	reload_options_list(options)

var pressed_timer:float = 0.0
func _process(delta:float):
	if SoundGroup.music.volume_db < 0.8:
		SoundGroup.music.volume_db += 2.5 * delta
	
	if not time_label == null and time_label.visible:
		var bttn:Alphabet = pause_group.get_child(cur_selection)
		time_label.position.x = bttn.position.x + bttn.width + 85
		time_label.position.y = bttn.position.y
	
	if Input.is_action_just_pressed("ui_up"):update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	
	if not time_label == null and time_label.visible:
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			var is_right = Input.is_action_just_pressed("ui_right")
			update_time(1 if is_right else -1)
			pressed_timer = 0.0
		
		var calc:float = int((pressed_timer / 1.0) * 10.0)
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			pressed_timer += delta
			
			var calc_post:float = int((pressed_timer / 1.0) * 10.0)
			var is_right = Input.is_action_pressed("ui_right")
			
			if pressed_timer > 0.5:
				update_time((calc - calc_post) * -1 if is_right else 1)

	if Input.is_action_just_pressed("ui_accept"):
		if active_list == difficulties:
			if active_list[cur_selection] == "back":
				reload_options_list(options)
			else:
				get_tree().paused = false
				SoundGroup.stop_music()
				Song.difficulty_name = active_list[cur_selection].to_lower()
				Main.reset_scene()
		else:
			match active_list[cur_selection]:
				"Resume":
					get_tree().paused = false
					SoundGroup.stop_music()
					queue_free()
				
				"Restart Song":
					get_tree().paused = false
					SoundGroup.stop_music()
					Main.reset_scene()
				
				"Jump Time to":
					get_tree().paused = false
					game.valid_score = false
					game.time_travelling = true
					game.seek_to(cur_time)
					game.time_travel_check()
					queue_free()
				
				"Change Difficulty": reload_options_list(difficulties)
				"Change Options": 
					Main.options_to_gameplay = true
					
					get_tree().paused = false
					SoundGroup.stop_music()
					SoundGroup.play_music(Paths.music("freakyMenu"), 0.7)
					Main.switch_scene("menus/OptionsMenu")
				
				"Exit to menu":
					SoundGroup.play_music(Paths.music("freakyMenu"), 0.7)
					# if get_tree().current_scene.play_mode == STORY: Main.switch_scene("menus/StoryMenu")
					# else:
					Main.switch_scene("menus/FreeplayMenu")

func update_selection(new_selection:int = 0):
	SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, active_list.size())
	update_list_items()

var cur_time:float = 0

func update_time(new_time:int = 0):
	if time_label.visible:
		var end_time:int = game.inst.stream.get_length()
		if cur_time == 0:
			cur_time = game.inst.get_playback_position()
		
		cur_time = wrapf(cur_time + new_time, 0, end_time)
		time_label.text = get_formatted_time(cur_time)

func update_list_items():
	var bs:int = 0
	for item in pause_group.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1 if item.id == 0 else 0.5
		bs+=1
	
	if time_label != null:
		time_label.visible = options[cur_selection] == "Jump Time to"

func reload_options_list(options_array:Array[String]):
	for child in pause_group.get_children():
		pause_group.remove_child(child)
	
	for i in options_array.size():
		var entry:Alphabet = $AlphabetTemp.duplicate()
		entry.position = Vector2(0, (60 * i))
		entry.text = options_array[i]
		#entry.vertical_spacing = 100
		entry.menu_item = true
		entry.id = i
		pause_group.add_child(entry)
	
	cur_selection = 0
	active_list = options_array
	update_list_items()

func get_formatted_time(value:int):
	return Tools.format_to_time(value).replace(":", ".")
