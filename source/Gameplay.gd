extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER}

const Pause_Screen = preload("res://source/gameplay/subScenes/PauseScreen.tscn")

var song:SongChart

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var song_name:String = "dadbattle"
var difficulty:String = "normal"

@onready var inst:AudioStreamPlayer = $Music/Inst
@onready var vocals:AudioStreamPlayer = $Music/Vocals

@onready var stage:Stage = $Objects/Stage
@onready var player:Character = $Objects/Player
@onready var opponent:Character = $Objects/Opponent
@onready var strum_lines:Control = $Strumlines
@onready var player_strums:StrumLine = $Strumlines/playerStrums
@onready var main_camera:Camera2D = $"Shifting Camera"

var noteList:Array[Note] = []

func _ready():
	change_cam(0)
	# set_process_input(true)
	
	if Song.difficulty_name != null: difficulty = Song.difficulty_name
	if !Song.ignore_song_queue and Song.song_queue.size() > 0:
		var _song:String = Song.song_queue[Song.queue_position]
		if song_name != _song:
			song_name = _song
	
	song = SongChart.load_chart(song_name, difficulty)
	noteList = song.load_notes()
	
	inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	
	inst.play()
	vocals.play()
	inst.finished.connect(end_song)
	
	for rating in ratings.keys(): ratings_gotten[rating] = 0
	for key in player_strums.receptors.get_child_count():
		keys_held.append(false)

func _process(_delta:float):
	if inst != null and inst.playing:
		Conductor.song_position = inst.get_playback_position() * 1000
	
	if $UI != null:
		update_score_text()
		$UI.update_health_bar(health)
	
	if Input.is_action_just_pressed("pause"):
		var pause = Pause_Screen.instantiate()
		get_tree().current_scene.add_child(pause)
		get_tree().paused = true
	# Load Notes
	spawn_notes()
	
	for strum_line in strum_lines.get_children():
		for note in strum_line.notes.get_children():
			
			# Kill Script
			var note_kill:int = 40
			if !strum_line.is_cpu:
				note_kill = 380+note.sustain_len
			
			if note.position.y > note_kill:
				if !strum_line.is_cpu and !note.was_good_hit:
					note_miss(note.direction)
				strum_line.remove_note(note)
		
		if (Input.is_action_just_pressed("reset")): health = 0

func spawn_notes():
	if noteList.size() > 0:
		var unspawned_note:Note = noteList[0]
		if (unspawned_note.time - Conductor.song_position < 3500):
			strum_lines.get_child(unspawned_note.strumLine).add_note(unspawned_note)
			noteList.remove_at(noteList.find(unspawned_note))

func beat_hit(beat:int):
	# 2 is temp
	if beat % 2==0:
		player.dance()
		opponent.dance()
	match song_name.to_lower():
		"bopeebo":
			if beat % 8==7: player.play_anim("hey")

func sect_hit(sect:int):
	if song.sections[sect] != null:
		change_cam(song.sections[sect].camera_position)

func change_cam(whose:int):
	var char := opponent
	match whose:
		1: char = player
		# 2: char = crowd
		_: char = opponent
	
	# main_camera.get_screen_center_position()
	main_camera.position = Vector2(
		char.get_viewport_rect().position.x,
		char.get_viewport_rect().position.y
	)

func end_song():
	Song.song_queue.pop_front()
	if Song.ignore_song_queue or Song.song_queue.size() <= 0:
		match play_mode:
			_: Main.switch_scene("menus/FreeplayMenu")
		return
	if Song.song_queue.size() > 0:
		Main.reset_scene()

# Input Functions
var keys_held:Array[bool] = []

func _input(input_event:InputEvent):
	if input_event is InputEventKey:
		var key_event:InputEventKey = input_event
		if key_event.pressed:
			match key_event.keycode:
				KEY_2: seek_to(inst.get_playback_position()+5)
				KEY_6:
					player_strums.is_cpu = !player_strums.is_cpu
					$UI.cpu_text.visible = player_strums.is_cpu
			
	var idx:int = get_input_dir()
	var dir:String = player_strums.dirs[idx]
	var receptor:AnimatedSprite2D = player_strums.receptors.get_child(idx)
	keys_held[idx] = Input.is_action_pressed("note_"+dir)
	
	var hit_notes:Array[Note] = []
	# cool thanks swordcube
	for note in player_strums.notes.get_children().filter(func(note:Note):
		return (note.direction == idx and !note.was_too_late and note.can_be_hit and note.player_note and not note.was_good_hit)	
	): hit_notes.append(note)
	
	# print("direction is "+dir+" and is being held? "+str(keys_held[idx]))
	if Input.is_action_pressed("note_"+dir):
		if !receptor.animation.ends_with("confirm"):
			receptor.play(dir+" press")
		
		# the actual dumb thing
		if hit_notes.size() > 0:
			for note in hit_notes:
				#if hit_dirs[idx]:
				note_hit(note, player, player_strums)
				receptor.play(dir+" confirm")
				
				# cool thanks swordcube
				if hit_notes.size() > 1:
					for i in hit_notes.size():
						if i == 0: continue
						var bad_note:Note = hit_notes[i]
						if absf(bad_note.time - note.time) <= 5 and note.direction == idx:
							bad_note.queue_free()
				break
		elif not Preferences.get_pref("ghost_tapping"): note_miss(idx)
	else: receptor.play("arrow"+dir.to_upper())

func sort_notes(a:Note, b:Note): return a.time < b.time

func get_input_dir():
	for i in player_strums.dirs.size():
		if (Input.is_action_just_pressed("note_"+player_strums.dirs[i])
			or Input.is_action_just_released("note_"+player_strums.dirs[i])):
				return i
	return -1

# Music Functions
func seek_to(time:float):
	inst.seek(time)
	vocals.seek(inst.get_playback_position())

# Score and Gameplay Functions
var score:int = 0
var misses:int = 0
var health:float = 50
var rating:String = "N/A"

const scoreSep:String = " • "

func update_score_text():
	var actual_acc:float = accuracy * 100 / 100
	
	var tmp_txt:String = "MISSES: "+str(misses)
	tmp_txt+=scoreSep+"SCORE: "+str(score)
	tmp_txt+=scoreSep+"ACCURACY: "+str("%.2f" % actual_acc)+"%"
	if rating.length() > 0:
		tmp_txt+=get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	$UI.score_text.bbcode_text = tmp_txt

func note_hit(note:Note, character:Character, strumline:StrumLine):
	if !note.was_good_hit:
		note.was_good_hit = true
		
		character.play_anim("sing" + strumline.dirs[note.direction].to_upper())
		
		# update accuracy
		notes_hit += 1
		update_note_acc(note)
		strumline.remove_note(note)

func note_miss(direction:int):
	misses+=1
	score+=ratings["miss"][0]
	notes_acc += ratings["miss"][1]
	health += ratings["miss"][3] / 50
	declare_rating()

# Accuracy Handling
var notes_hit:int = 0
var notes_acc:float = 0
var accuracy:float:
	get:
		if notes_acc < 1: return 0.00
		else: return (notes_acc / notes_hit)

# Dictionary Order:
# Score (Integer),Accuracy Gain (Int), Timing (Float), Health Gain (Integer)
var ratings:Dictionary = {
	"sick": [350, 100, 45.0, 100],
	"good": [150, 75, 90.0, 30],
	"bad": [50, 30, 135.0, -20],
	"shit": [-30, -20, 160.0, -20],
	"miss": [-50, -40, null, -50] # Miss has no timings
}

var ratings_gotten:Dictionary = {}

func update_note_acc(note:Note):
	if notes_acc < 0: notes_acc = 0.00001
	var note_diff:float = absf(Conductor.song_position - note.time)
	var _rating:String = "sick"
	
	# if note_diff > Conductor.safe_zone * 0.9: rating = "shit"
	# if note_diff > Conductor.safe_zone * 0.7: rating = "bad"
	# if note_diff > Conductor.safe_zone * 0.2: rating = "good"
	
	notes_acc += maxf(0, ratings[_rating][1])
	health += ratings[_rating][3] / 50
	ratings_gotten[_rating] += 1
	declare_rating()

func get_clear_type():
	var rating_colors:Dictionary = {
		"MFC": "CYAN",
		"GFC": "LIME",
		"FC": "LIGHT_SLATE_GRAY",
		"SDCB": "CRIMSON"
	}
	
	# overenginered bullshit
	var markup:String = ""
	var markup_end:String = ""
	if rating_colors.get(rating) != null:
		markup = "[color="+rating_colors.get(rating)+"]"
		markup_end = "[/color]"
	
	# return colored rating if it exists on the rating colors dictio
	var colored_rating:String = " ["+markup+rating+markup_end+"]"
	return colored_rating if markup != "" else " ["+rating+"]" if rating != "" else ""

func declare_rating():
	rating = ""
	if misses == 0:
		if ratings_gotten["sick"] > 0: rating = "MFC"
		if ratings_gotten["good"] > 0: rating = "GFC"
		if ratings_gotten["bad"] or ratings_gotten["shit"] > 0: rating = "FC"
	elif misses < 10: rating = "SDCB"
