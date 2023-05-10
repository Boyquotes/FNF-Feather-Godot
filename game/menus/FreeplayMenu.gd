extends Node2D

var cur_selection:int = 0
var cur_difficulty:int = 1
var last_selection:int = -1
var last_difficulty:String = "none"

@onready var bg:Sprite2D = $Background
@onready var score_bg:Sprite2D = $UI/Score/score_bg
@onready var score_text:Label = $UI/Score/score_label
@onready var diff_text:Label = $UI/Score/diff_label

@export var songs:Array[FreeplaySong] = []

@onready var song_group:Node = $"Song Group"
@onready var icon_group:Node = $"Icon Group"

var local_queue:Array[String] = []
@onready var local_queue_txt:Label = $UI/Queue/queue_songs

func _ready():
	local_queue_txt.text = ""
	icon_group = Node.new()
	add_child(icon_group)
	
	for i in songs.size():
		if songs[i] == null: return
		var song_entry:Alphabet = Alphabet.new(songs[i].name, true, 60, (70 * i) + 30)
		song_entry.id = i
		song_entry._raw_text = songs[i].folder
		song_entry.menu_item = true
		song_group.add_child(song_entry)
		
		var song_icon:HealthIcon = HealthIcon.new(songs[i].icon)
		song_icon.attached = song_entry
		song_icon.hframes = songs[i].icon_frames
		icon_group.add_child(song_icon)
	
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	if Input.is_action_just_pressed("ui_left"): update_difficulty(-1)
	if Input.is_action_just_pressed("ui_right"): update_difficulty(1)
	if Input.is_action_just_pressed("ui_accept"):
		Song.song_queue = []
		if local_queue.size() > 0:
			Song.song_queue = local_queue
		else:
			Song.song_queue.append(songs[cur_selection].folder)
		SoundGroup.stop_music()
		Song.difficulty_name = diff_text.text.to_lower().replace('< ', '').replace(' >', '')
		Main.switch_scene("Note Test")
	if Input.is_action_just_pressed("ui_cancel"):
		if !Input.is_action_pressed("reset"):
			SoundGroup.play_music(Paths.music("freakyMenu"))
		Main.switch_scene("menus/MainMenu")

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.is_pressed():
		match keyEvent.keycode:
			KEY_SPACE: play_selected_song()
			KEY_CTRL: add_selection_to_queue()

var bg_tween:Tween
func update_selection(new_selection:int = 0):
	if new_selection != 0: SoundGroup.play_sound(Paths.sound("scrollMenu"))
	cur_selection = wrapi(cur_selection+new_selection, 0, songs.size())
	
	update_list_items()
	bg_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	bg_tween.tween_property(bg, "modulate", songs[cur_selection].color, 0.8)
	update_difficulty()
	
	last_selection = cur_selection

func update_difficulty(new_difficulty:int = 0):
	var diff_arr:Array[String] = Song.default_diffs
	if songs[cur_selection].difficulties.size() > 0:
		diff_arr = songs[cur_selection].difficulties
	
	if diff_arr.size() > 1:
		if (last_selection != cur_selection and diff_arr.has(last_difficulty)
				and diff_arr[cur_difficulty] != last_difficulty):
			cur_difficulty = diff_arr.find(last_difficulty)
	
	# actually change the difficulty
	cur_difficulty = wrapi(cur_difficulty+new_difficulty, 0, diff_arr.size())
	diff_text.text = diff_arr[cur_difficulty].to_upper()
	
	if diff_arr.size() > 1:
		if new_difficulty != 0:
			SoundGroup.play_sound(Paths.sound("scrollMenu"))
		diff_text.text = '< '+diff_text.text+' >'
	if diff_arr[cur_difficulty] != last_difficulty:
		last_difficulty = diff_arr[cur_difficulty]

func add_selection_to_queue():
	if local_queue.has(songs[cur_selection].folder):
		local_queue.erase(songs[cur_selection].folder)
	else:
		local_queue.append(songs[cur_selection].folder)
	
	update_local_queue()
	update_list_items()

func update_list_items():
	var bs:int = 0
	for item in song_group.get_children():
		item.id = bs - cur_selection
		item.modulate = Color.LIME if local_queue.has(item._raw_text) else Color.WHITE
		if item.id == 0: item.modulate.a = 1
		else: item.modulate.a = 0.5
		bs+=1

func play_selected_song():
	# change current song
	if ResourceLoader.exists(Paths.songs(songs[cur_selection].folder+"/Inst.ogg")):
		SoundGroup.play_music(Paths.songs(songs[cur_selection].folder+"/Inst.ogg"), 0.5, true)
	else: SoundGroup.play_music(Paths.music("freakyMenu"), 0.5, true)

func update_local_queue():
	# Clear if too big
	if local_queue.size() > 20:
		local_queue = []
	
	local_queue_txt.text = ""
	for i in local_queue.size():
		var song:String = folder_to_name(local_queue[i]).to_upper()
		local_queue_txt.text += str(i+1)+': '+song+'\n'
	
	var module_alpha:float = 1 if local_queue.size() > 0 else 0
	var twn:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	twn.tween_property($UI/Queue, "modulate:a", module_alpha, 0.4)

func folder_to_name(folder:String):
	for i in songs.size():
		if songs[i].folder == folder:
			return songs[i].name
	return "null"
