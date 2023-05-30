extends Node2D

var cur_selection:int = 0
var cur_difficulty:int = 1
var last_selection:int = -1
var last_difficulty:String = "none"

@onready var bg:Sprite2D = $Background
@onready var score_bg:ColorRect = $UI/Score/score_bg
@onready var score_text:Label = $UI/Score/score_label
@onready var diff_text:Label = $UI/Score/diff_label

@export var songs:Array[FreeplaySong] = []

@onready var song_group:Node = $"Song Group"
@onready var icon_group:Node = $"Icon Group"

var local_queue:Array[String] = []
@onready var local_queue_txt:Label = $UI/Queue/queue_songs

func _ready():
	Main.change_rpc("FREEPLAY MENU", "In the Menus")
	
	# just for testing
	if ResourceLoader.exists("res://assets/freeplaySonglist.tres"):
		var user_songs:FreeplaySongArray = load("res://assets/freeplaySonglist.tres")
		for song in user_songs.songs:
			if not songs[songs.size() - 1].name == song.name:
				songs.append(song)
	
	$"UI/Tooltip Scale".text = "SCALE: "+str(Conductor.song_scale)+"x"
	local_queue_txt.text = ""
	
	for i in songs.size():
		if songs[i] == null: return
		var song_entry:Alphabet = $AlphabetTemp.duplicate()
		
		song_entry.bold = true
		song_entry.visible = true
		song_entry.text = songs[i].name
		song_entry.position = Vector2(60, (70 * i) + 30)
		
		song_entry.id = i
		song_entry._raw_text = songs[i].folder
		song_entry.menu_item = true
		song_group.add_child(song_entry)
		
		var song_icon:HealthIcon = HealthIcon.new(songs[i].icon)
		song_icon.attached = song_entry
		song_icon.hframes = songs[i].icon_frames
		icon_group.add_child(song_icon)
	
	update_selection()

var score_lerp:int = 0
var score_final:int = 0

func _process(delta:float):
	if SoundGroup.music.volume_db < 0.5:
		SoundGroup.music.volume_db += 80.0 * delta
	
	score_lerp = lerp(score_lerp, score_final, 0.30)
	score_text.text = "PERSONAL BEST:" + str(score_lerp)
	_position_highscore()
	
	# Selection Changers
	if Input.is_action_just_pressed("ui_up"): update_selection(-1)
	if Input.is_action_just_pressed("ui_down"): update_selection(1)
	
	# Difficulty Changers
	if Input.is_action_just_pressed("ui_left"): update_difficulty(-1)
	if Input.is_action_just_pressed("ui_right"): update_difficulty(1)
	
	# Other Actions
	if Input.is_action_just_pressed("ui_accept"):
		Song.song_queue = []
		if local_queue.size() > 0:
			Song.song_queue = local_queue
		else:
			Song.song_queue.append(songs[cur_selection].folder)
		
		Song.song_name = songs[cur_selection].name
		SoundGroup.stop_music()
		Song.difficulty_name = diff_text.text.to_lower().replace('< ', '').replace(' >', '')
		
		SoundGroup.music.pitch_scale = 1.0
		Main.switch_scene("Gameplay", "game/scenes/gameplay")
	
	if Input.is_action_just_pressed("ui_cancel"):
		if !Input.is_key_pressed(KEY_SHIFT) and SoundGroup.music_file != Paths.music("freakyMenu"):
			SoundGroup.play_music(Paths.music("freakyMenu"))
		
		if SoundGroup.music_file == Paths.music("freakyMenu"):
			SoundGroup.music.pitch_scale = 1.0
		Main.switch_scene("menus/MainMenu")

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.is_pressed():
		match keyEvent.keycode:
			KEY_CTRL: add_selection_to_queue()
			KEY_Q:
				Conductor.song_scale -= 0.01
				$"UI/Tooltip Scale".text = "SCALE: "+str(Conductor.song_scale)+"x"
				SoundGroup.music.pitch_scale = Conductor.song_scale
			KEY_E:
				Conductor.song_scale += 0.01
				$"UI/Tooltip Scale".text = "SCALE: "+str(Conductor.song_scale)+"x"
				SoundGroup.music.pitch_scale = Conductor.song_scale

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
	var diff_arr:Array[String] = songs[cur_selection].difficulties
	if diff_arr.size() > 1:
		if (last_selection != cur_selection and diff_arr.has(last_difficulty)
				and diff_arr[cur_difficulty] != last_difficulty):
			cur_difficulty = diff_arr.find(last_difficulty)
	
	Song.difficulties = diff_arr
	
	# actually change the difficulty
	cur_difficulty = wrapi(cur_difficulty+new_difficulty, 0, diff_arr.size())
	diff_text.text = diff_arr[cur_difficulty].to_upper()
	
	if diff_arr.size() > 1:
		if new_difficulty != 0:
			SoundGroup.play_sound(Paths.sound("scrollMenu"))
		diff_text.text = '< '+diff_text.text+' >'
	if diff_arr[cur_difficulty] != last_difficulty:
		last_difficulty = diff_arr[cur_difficulty]
	
	score_final = Song.get_score(songs[cur_selection].folder, \
		diff_arr[cur_difficulty])
	
	await(get_tree().create_timer(0.15).timeout)
	play_selected_song()

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
		item.modulate.a = 1 if item.id == 0 else 0.5
		bs+=1

func play_selected_song():
	# change current song
	var def_inst = Paths.songs(songs[cur_selection].folder+"/Inst.ogg")
	var diff_inst = Paths.songs(songs[cur_selection].folder+"/Inst" + "-" + last_difficulty.to_lower() + ".ogg")
	
	if ResourceLoader.exists(diff_inst) and SoundGroup.music_file != diff_inst:
		SoundGroup.play_music(diff_inst, -50.0, true)
	
	elif ResourceLoader.exists(def_inst) and SoundGroup.music_file != def_inst:
		SoundGroup.play_music(def_inst, -50.0, true)
	
	SoundGroup.music.seek(randi_range(0, SoundGroup.music.stream.get_length() / 2.0))

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
	return ""

func _position_highscore():
	score_text.size.x = 0
	score_text.position.x = Main.SCREEN["width"] - score_text.size.x - 6
	
	score_bg.position.x = score_text.position.x - 3
	score_bg.size.x = Main.SCREEN["width"] - score_text.size.x / 2.0
	
	diff_text.position.x = score_bg.position.x
	diff_text.size.x = score_text.size.x / 1.0
