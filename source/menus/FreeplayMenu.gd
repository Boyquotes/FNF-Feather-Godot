extends Node2D

var cur_selection:int = 0
var cur_difficulty:int = 1

@onready var bg:Sprite2D = $Background
@onready var score_bg = $UI/score_bg
@onready var score_text = $UI/score_label
@onready var diff_text = $UI/diff_label

@export var songs:Array[FreeplaySong] = []
var song_group:AlphabetNode

var local_queue:Array[String] = []

func _ready():
	song_group = AlphabetNode.new()
	add_child(song_group)
	
	for i in songs.size():
		if songs[i] == null: return
		var song_entry:Alphabet = Alphabet.new(songs[i].name, 0, 60 * i)
		song_entry.id = i
		song_entry._raw_text = songs[i].folder
		song_entry.menu_item = true
		song_group.add_child(song_entry)
	
	update_selection()

func _process(delta):
	pass

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_UP: update_selection(-1)
			KEY_DOWN: update_selection(1)
			KEY_LEFT: update_difficulty(-1)
			KEY_RIGHT: update_difficulty(1)
			KEY_CTRL: add_selection_to_queue()
			KEY_ALT:
				local_queue.clear()
				update_list_items()
			KEY_ENTER:
				Song.song_queue = []
				if local_queue.size() > 0:
					Song.song_queue = local_queue
				else:
					Song.song_queue.append(songs[cur_selection].folder)
				Song.difficulty_name = diff_text.text.to_lower().replace('< ', '').replace(' >', '')
				Main.switch_scene("Gameplay")
			KEY_ESCAPE: Main.switch_scene("menus/MainMenu")

var bg_tween:Tween
func update_selection(new_selection:int = 0):
	cur_selection = clampi(cur_selection + new_selection, 0, songs.size() -1)
	#$scroll_sound.play(0.0)
	update_list_items()
	bg_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	bg_tween.tween_property(bg, "modulate", songs[cur_selection].color, 0.8)
	update_difficulty()

func update_difficulty(new_difficulty:int = 0):
	var diff_arr:Array[String] = Song.default_diffs
	if songs[cur_selection].difficulties.size() > 0: diff_arr = songs[cur_selection].difficulties
	cur_difficulty = clampi(cur_difficulty + new_difficulty, 0, diff_arr.size() -1)
	diff_text.text = diff_arr[cur_difficulty].to_upper()
	if diff_arr.size() > 1: diff_text.text = '< ' + diff_text.text + ' >'

func add_selection_to_queue():
	print(local_queue)
	if local_queue.has(songs[cur_selection].folder):
		local_queue.erase(songs[cur_selection].folder)
	else:
		local_queue.append(songs[cur_selection].folder)
	update_list_items()

func update_list_items():
	var bs:int = 0
	for item in song_group.get_children():
		item.id = bs - cur_selection
		item.modulate = Color.LIME if local_queue.has(item._raw_text) else Color.WHITE
		item.modulate.a = 1 if item.id == 0 else 0.7
		bs += 1
