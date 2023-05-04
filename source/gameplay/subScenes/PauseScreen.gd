extends CanvasLayer

@export var options:Array[String] = ["Resume", "Restart Song", "Exit to menu"]
@onready var bg:Sprite2D = $Background
@onready var info:Label = $Info

var cur_selection:int = 0
var pause_group:AlphabetNode
var info_label:Label

func _ready():
	AudioHelper.play_music(Paths.music("breakfast"), -30, true)
	
	pause_group = AlphabetNode.new()
	add_child(pause_group)
	
	for i in options.size():
		var entry:Alphabet = Alphabet.new(options[i], true, 0, (60 * i))
		entry.menu_item = true
		entry.id = i
		pause_group.add_child(entry)
	
	if get_tree().current_scene.song_name != null:
		info.text = info.text.replace("Test", get_tree().current_scene.song_name.to_pascal_case())
		info.text = info.text.replace("HARD", Song.difficulty_name.to_upper())
	update_list_items()

func _process(delta):
	if AudioHelper.music.volume_db < 0.8:
		AudioHelper.music.volume_db += 2.5 * delta
	
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		AudioHelper.stop_music()
		match options[cur_selection]:
			"Restart Song": Main.switch_scene("Gameplay")
			"Exit to menu":
				# if mode == STORY: Main.switch_scene("menus/StoryMenu")
				# else:
				Main.switch_scene("menus/FreeplayMenu")
		queue_free()

func update_selection(new_selection:int = 0):
	AudioHelper.play_sound("SCROLL_MENU")
	cur_selection = wrapi(cur_selection+new_selection, 0, options.size())
	update_list_items()
	
func update_list_items():
	var bs:int = 0
	for item in pause_group.get_children():
		item.id = bs - cur_selection
		if item.id == 0: item.modulate.a = 1
		else: item.modulate.a = 0.7
		bs+=1
