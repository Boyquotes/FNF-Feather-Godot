extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER}

var note_paths:Dictionary = {
	"default": "res://game/gameplay/notes/Default.tscn"
}

var note_scenes:Dictionary = {
	"default": preload("res://game/gameplay/notes/Default.tscn").instantiate()
}

const Pause_Screen = preload("res://game/gameplay/subScenes/PauseScreen.tscn")

var song:SongChart

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var song_name:String = "dadbattle"
var difficulty:String = "normal"

@onready var inst:AudioStreamPlayer = $Inst
@onready var vocals:AudioStreamPlayer = $Vocals

@onready var stage:Stage = $Objects/Stage
@onready var player:Character = $Objects/Player
@onready var opponent:Character = $Objects/Opponent
@onready var strum_lines:CanvasLayer = $Strumlines

@onready var player_strums:StrumLine = $Strumlines/playerStrums
@onready var cpu_strums:StrumLine = $Strumlines/cpuStrums

@onready var camera:Camera2D = $"Main Camera"
@onready var ui:CanvasLayer = $UI

var began_count:bool = false
var beginning_song:bool = true

var notes_list:Array[ChartNote] = []

func _init():
	super._init()
	
	if Song.difficulty_name != null: difficulty = Song.difficulty_name
	if !Song.ignore_song_queue and Song.song_queue.size() > 0:
		var _song:String = Song.song_queue[Song.queue_position]
		if song_name != _song:
			song_name = _song
	song = SongChart.load_chart(song_name, difficulty)
	notes_list = song.load_chart_notes()
	
	#for n in notes_list:
		#if not n.type in note_scenes:
			#note_scenes[n.type] = load(note_paths[n.type]).instantiate()

func _ready():
	# Music Setup
	inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	if ResourceLoader.exists(Paths.songs(song_name+"/Voices.ogg")):
		vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	
	# making sure it doesn't loop
	inst.stream.loop = false
	if vocals.stream != null:
		vocals.stream.loop = false
	inst.finished.connect(end_song)
	
	# Camera Setup
	change_camera_position(song.sections[0].camera_position)
	camera.zoom = Vector2(stage.camera_zoom, stage.camera_zoom)
	
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 3*stage.camera_speed
	
	# User Interface Setup
	ui.icon_PL.load_icon(player.icon_name)
	ui.icon_OPP.load_icon(opponent.icon_name)
	
	if Settings.get_setting("center_notes"):
		player_strums.position.x = Main.SCREEN["center"].x / 1.5
	
	# Generate the Receptors
	for i in strum_lines.get_children():
		i._generate_receptors()
	if Settings.get_setting("center_notes"):
		cpu_strums.modulate.a = 0
	
	if Settings.get_setting("downscroll"):
		for strum_line in strum_lines.get_children():
			strum_line.position.y = 550
		ui.health_bar.position.y = 54
		ui.score_text.position.y = 92
	
	# set up rating amounts
	for rating in ratings.keys():
		ratings_gotten[rating] = 0
	
	update_score_text()
	update_counter_text()
	
	$Darkness.modulate.a = Settings.get_setting("stage_darkness") * 0.01
	
	# set up hold inputs
	for key in player_strums.receptors.get_child_count():
		keys_held.append(false)
	
	# start count
	begin_countdown()

func _process(delta:float):
	if inst != null:
		if not beginning_song and began_count:
			update_song_pos(delta)
			Conductor.song_position = _song_time
		else:
			Conductor.song_position += delta * 1000
			if Conductor.song_position >= 0:
				start_song()
	
	if ui != null:
		ui.update_health_bar(health)
		update_timer_text()
	
	if Input.is_action_just_pressed("pause"):
		get_tree().current_scene.add_child(Pause_Screen.instantiate())
		get_tree().paused = true
	
	# Load Notes
	spawn_notes()
	
	# UI Icon Reset
	ui.icons_bounce()
	
	if Input.is_action_just_pressed("reset"):
		health = 0

func spawn_notes():
	for note in notes_list:
		if note.step_time - Conductor.song_position > 3500:
			break
		
		var queued_type:String = note.type
		if not note_paths.has(note.type):
			print("note of type \""+note.type+"\" can't be spawned")
			queued_type = "default"
		
		var queued_note:Note = Note.new(note.step_time, note.direction, queued_type, note.length)
		# queued_note.time = note.step_time
		# queued_note.direction = note.direction
		# queued_note.type = queued_type
		# queued_note.sustain_len = note.length
		queued_note.strum_line = note.strum_line
		
		strum_lines.get_child(note.strum_line).add_note(queued_note)
		notes_list.erase(note)

func beat_hit(beat:int):
	var characters:Array[Character] = [player, opponent]
	for char in characters:
		if beat % char.bopping_time == 0:
			if (not char.is_singing() or
				char.is_singing() and char.finished_playing):
				char.dance()
	
	ui.icons_bounce(beat)

func sect_hit(sect:int):
	if sect > song.sections.size():
		sect = 0
	
	if song.sections[sect] == null: return
	change_camera_position(song.sections[sect].camera_position)

func change_camera_position(whose:int):
	var char:Character = opponent
	match whose:
		1: char = player
		# 2: char = crowd
		_: char = opponent
	
	var offset:Vector2 = Vector2(char.camera_offset.x + stage.camera_offset.x, char.camera_offset.y + stage.camera_offset.y)
	camera.position = Vector2(char.get_camera_midpoint().x + offset.x, char.get_camera_midpoint().y + offset.y)

func update_timer_text():
	var song_pos:float = inst.get_playback_position()
	var length:float = inst.stream.get_length()
	
	ui.timer_progress.text = Tools.format_to_time(song_pos)
	ui.timer_length.text = Tools.format_to_time(length)

func start_song():
	beginning_song = false
	play_music()

func end_song():
	stop_music()
	if not Song.ignore_song_queue:
		Song.song_queue.pop_front()
		if Song.song_queue.size() > 0:
			Main.reset_scene()
		else: go_to_menu()
	else: go_to_menu()

func go_to_menu():
	SoundGroup.play_music(Paths.music("freakyMenu"), 0.7)
	match play_mode:
		_: Main.switch_scene("menus/FreeplayMenu")

# Input Functions
var keys_held:Array[bool] = []

func _input(key:InputEvent):
	if key is InputEventKey:
		if key.pressed: match key.keycode:
			KEY_2: seek_to(inst.get_playback_position()+5)
			KEY_6:
				player_strums.is_cpu = !player_strums.is_cpu
				ui.cpu_text.visible = player_strums.is_cpu
		_note_input(key)

func _note_input(event:InputEventKey):
	var idx:int = get_input_dir(event)
	var action:String = "note_"+Tools.dirs[idx]
	var pressed:bool = Input.is_action_pressed(action)
	var just_pressed:bool = Input.is_action_just_pressed(action)
	var released:bool = Input.is_action_just_released(action)
	
	if idx < 0 or player_strums.is_cpu:
		return
	
	keys_held[idx] = pressed
	
	var hit_notes:Array[Note] = []
	# cool thanks swordcube
	for note in player_strums.notes.get_children().filter(func(note:Note):
		return (note.direction == idx and !note.was_too_late and note.can_be_hit and note.must_press and not note.was_good_hit)
	): hit_notes.append(note)
	
	var receptor:AnimatedSprite2D = player_strums.receptors.get_child(idx)
	var r_action:String = action.replace("note_", "")
	
	if just_pressed:
		if !receptor.animation.ends_with("confirm"):
			receptor.play(r_action+" press")
		
		# the actual dumb thing
		if hit_notes.size() > 0:
			for note in hit_notes:
				note_hit(note)
				receptor.play(r_action+" confirm")
				
				# cool thanks swordcube
				if hit_notes.size() > 1:
					for i in hit_notes.size():
						if i == 0: continue
						var bad_note:Note = hit_notes[i]
						if absf(bad_note.time - note.time) <= 5 and note.direction == idx:
							bad_note.queue_free()
				break
		elif not Settings.get_setting("ghost_tapping"):
			note_miss(idx)
	
	if released: receptor.play("arrow"+r_action.to_upper())

func sort_notes(a:Note, b:Note): return a.time < b.time

func get_input_dir(e:InputEventKey):
	for i in Tools.dirs.size():
		var a:StringName = "note_"+Tools.dirs[i]
		if e.is_action_pressed(a) or e.is_action_released(a):
			return i
			break
	return -1

# Music Functions
func seek_to(time:float):
	inst.seek(time)
	if vocals.stream != null:
		vocals.seek(inst.get_playback_position())

func stop_music():
	inst.stop()
	if vocals.stream != null:
		vocals.stop()

func play_music(time:float = 0.0):
	inst.play(time)
	if vocals != null:
		vocals.play(time)

# Score and Gameplay Functions
var score:int = 0
var misses:int = 0
var combo:int = 0
var health:float = 50
var rating:String = "N/A"

const score_div:String = " • "

func update_score_text():
	var actual_acc:float = accuracy * 100 / 100
	
	var tmp_txt:String = "SCORE: ["+str(score)+"]"
	tmp_txt+=score_div+"ACCURACY: ["+str("%.2f" % actual_acc)+"%]"
	tmp_txt+=score_div+"RANK: "+get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	ui.score_text.bbcode_text = tmp_txt
	ui.score_text.position.x = ui.health_bar_width/1.45

func update_counter_text():
	if ui.counter == null:
		return
	
	var counter_div:String = '\n'
	if Settings.get_setting("rating_counter") == "horizontal":
		counter_div = score_div
	
	var tmp_txt:String = ""
	for i in ratings_gotten:
		tmp_txt += i.to_pascal_case()+': '+str(ratings_gotten[i])+counter_div
	tmp_txt += 'Miss: '+str(misses)
	ui.counter.text = tmp_txt
	
	match Settings.get_setting("rating_counter"):
		"right":
			ui.counter.position.x = 1185
		"horizontal":
			ui.counter.position.x = ui.health_bar_width/1.7
			if Settings.get_setting("downscroll"):
				ui.counter.position.y = ui.cpu_text.position.y + 90
			else:
				ui.counter.position.y = 10
		

func note_hit(note:Note):
	if !note.was_good_hit:
		note.was_good_hit = true
		note.note_hit(true)
		
		if vocals.stream != null: vocals.volume_db = 0
		player.play_anim("sing"+Tools.dirs[note.direction].to_upper(), true)
		player.hold_timer = 0.0
		
		# update accuracy
		notes_hit += 1
		combo += 1
		get_rating_from_time(note)
		player_strums.remove_note(note)

func note_miss(direction:int):
	misses+=1
	if vocals.stream != null: vocals.volume_db = -50
	
	# decrease gameplay values
	const miss_val:int = 50
	score-=miss_val
	notes_acc-=40
	health-=miss_val / 50
	
	update_clear_type()
	update_score_text()
	update_counter_text()

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
	"shit": [-30, -20, 160.0, -20]
}

var ratings_gotten:Dictionary = {}

func get_rating_from_time(note:Note):
	if notes_acc < 0: notes_acc = 0.00001
	var note_diff:float = absf(Conductor.song_position - note.time)
	
	var _rating:String = "sick"
	for judge in ratings.keys():
		var ms_threshold:float = ratings[judge][2]
		var ms_max_thre:float = 0.0
		if note_diff > ms_threshold and ms_max_thre < ms_threshold:
			_rating = judge
			ms_max_thre = ms_threshold
	
	score += ratings[_rating][0]
	notes_acc += maxf(0, ratings[_rating][1])
	health += ratings[_rating][3] / 50
	ratings_gotten[_rating] += 1
	update_counter_text()
	update_clear_type()
	update_score_text()

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
	var colored_rating:String = "["+markup+rating+markup_end+"]"
	return colored_rating if markup != "" else "["+rating+"]" if rating != "" else ""

func update_clear_type():
	rating = ""
	if misses == 0:
		if ratings_gotten["sick"] > 0: rating = "MFC"
		if ratings_gotten["good"] > 0: rating = "GFC"
		if ratings_gotten["bad"] or ratings_gotten["shit"] > 0: rating = "FC"
	elif misses < 10:
		rating = "SDCB"
	else: rating = "CLEAR"
	
var _song_time:float = 0

func update_song_pos(_delta):
	_song_time += _delta * 1000
	
	if (abs((inst.get_playback_position() * 1000) -  _song_time) > 30):
		_song_time = inst.get_playback_position() * 1000

func begin_countdown():
	began_count = true
	Conductor.song_position = -Conductor.crochet * 5;
	await(get_tree().create_timer(0.05).timeout)
	process_countdown()

var count_tween:Tween
var count_position:int = 0
func process_countdown():
	if count_tween != null:
		count_tween.stop()
	
	count_position = 0
	
	var sounds:Array[String] = ["intro3", "intro2", "intro1", "introGo"]
	
	for i in 4: # process 4 times
		var countdown_sprite:Sprite2D = $UI/Countdown.get_child(count_position)
		count_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		count_tween.tween_property(countdown_sprite, "modulate:a", 1, 0.1)
		SoundGroup.play_sound(Paths.sound("game/base/" + sounds[count_position]))
		
		await(get_tree().create_timer(Conductor.crochet/1000).timeout)
		
		count_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		count_tween.tween_property(countdown_sprite, "modulate:a", 0, 0.5)
		count_position += 1
