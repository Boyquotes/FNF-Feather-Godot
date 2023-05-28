extends CanvasLayer

@export var options:Array[String] = ["Resume", "Restart Song", "Change Options", "Exit to menu"]
@onready var bg:Sprite2D = $Background
@onready var info:Label = $Info

var active_list:Array[String] = []
var difficulties:Array[String] = []

var finished_tween:bool = false
var cur_selection:int = 0
var pause_group:Node
var info_label:Label

func _ready():
	SoundGroup.play_music(Paths.music("breakfast"), -30, true)
	
	if Song.active_difficulties.size() > 1:
		options.insert(2, "Change Difficulty")
		for i in Song.active_difficulties:
			difficulties.append(i)
		difficulties.append("back")
	
	pause_group = Node.new()
	add_child(pause_group)
	
	reload_options_list(options)
	
	if get_tree().current_scene.song_name != null:
		info.text = info.text.replace("Test", get_tree().current_scene.song_name.to_pascal_case())
		info.text = info.text.replace("HARD", Song.difficulty_name.to_upper())

func _process(delta):
	if SoundGroup.music.volume_db < 0.8:
		SoundGroup.music.volume_db += 2.5 * delta
	
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
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
	
func update_list_items():
	var bs:int = 0
	for item in pause_group.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1 if item.id == 0 else 0.5
		bs+=1

func reload_options_list(options_array:Array[String]):
	for child in pause_group.get_children():
		pause_group.remove_child(child)
	
	for i in options_array.size():
		var entry:Alphabet = $AlphabetTemp.duplicate()
		entry.position = Vector2(0, (60 * i))
		entry.text = options_array[i]
		entry.vertical_spacing = 100
		entry.menu_item = true
		entry.id = i
		pause_group.add_child(entry)
	
	cur_selection = 0
	active_list = options_array
	update_list_items()
