extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER}

const Pause_Screen = preload("res://game/scenes/subScenes/PauseScreen.tscn")
const Game_Over_Screen = preload("res://game/scenes/subScenes/GameOver.tscn")

@onready var camera:Camera2D = $"Game_Camera"

### SONG AND AUDIO ###
var song:SongChart

@onready var inst:AudioStreamPlayer = $Inst
@onready var vocals:AudioStreamPlayer = $Vocals

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var song_name:String = "dadbattle"
var difficulty:String = "normal"

### OBJECTS ###
var player:Character
var opponent:Character
var crowd:Character
var stage:Stage

@onready var objects:Control = $Objects

### USER INTERFACE ###
@onready var judgement_group:CanvasGroup = $Judgement_Group
@onready var combo_group:CanvasGroup = $Combo_Group

@onready var ui:CanvasLayer = $UI
@onready var strum_lines:CanvasLayer = $Strumlines

@onready var player_strums:StrumLine = $Strumlines/player_Strums
@onready var cpu_strums:StrumLine = $Strumlines/cpu_Strums

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

func _ready():
	# Character Setup
	for i in 3:
		if not ResourceLoader.exists(Paths.character_scene(song.characters[i])):
			song.characters[i] = "bf"
	
	var stage_path:String = "res://game/scenes/gameplay/stages/"+song.stage+".tscn"
	if not ResourceLoader.exists("res://game/scenes/gameplay/stages/"+song.stage+".tscn"):
		stage_path = "res://game/scenes/gameplay/stages/stage.tscn"
	
	stage = load(stage_path).instantiate()
	objects.add_child(stage)
	
	opponent = load(Paths.character_scene(song.characters[1])).instantiate()
	crowd = load(Paths.character_scene(song.characters[2])).instantiate()
	player = load(Paths.character_scene(song.characters[0])).instantiate()
	
	opponent.is_player = false
	crowd.is_player = false
	
	opponent.position = stage.opponent_position
	crowd.position = stage.crowd_position
	player.position = stage.player_position
	
	objects.add_child(opponent)
	#if stage.hide_crowd:
	objects.add_child(crowd)
	objects.add_child(player)
	
	# Music Setup
	var diff_inst = Paths.songs(song_name+"/Inst" + "-" + difficulty + ".ogg")
	var diff_vocals = Paths.songs(song_name+"/Voices" + "-" + difficulty + ".ogg")
	var diff_inst_loaded:bool = false
	
	if ResourceLoader.exists(diff_inst):
		inst.stream = load(diff_inst)
		diff_inst_loaded = true
	else: inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	
	if ResourceLoader.exists(diff_vocals): vocals.stream = load(diff_vocals)
	elif ResourceLoader.exists(Paths.songs(song_name+"/Voices.ogg")) and not diff_inst_loaded:
		vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	
	# making sure it doesn't loop
	inst.stream.loop = false
	if vocals.stream != null:
		vocals.stream.loop = false
	inst.finished.connect(end_song)
	
	inst.pitch_scale = Conductor.song_scale
	if vocals.stream != null:
		vocals.pitch_scale = Conductor.song_scale
	
	# Camera Setup
	change_camera_position(song.sections[0].camera_position)
	
	camera.zoom = Vector2(stage.camera_zoom, stage.camera_zoom)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 3*stage.camera_speed
	
	# User Interface Setup
	ui.icon_PL.load_icon(player.icon_name)
	ui.icon_OPP.load_icon(opponent.icon_name)
	
	# set up judgement amounts
	for i in judgements.size():
		var judge = judgements[i].name
		judgements_gotten[judge] = 0
	
	if Settings.get_setting("hud_judgements"):
		remove_child(judgement_group)
		remove_child(combo_group)
		
		ui.add_child(judgement_group)
		ui.add_child(combo_group)
	
	if Settings.get_setting("center_notes"):
		player_strums.position.x = Main.SCREEN["center"].x / 1.50
	# Generate the Receptors
	for i in strum_lines.get_children():
		if i is StrumLine:
			i._generate_receptors()
	
	if Settings.get_setting("center_notes"):
		# cpu_strums.modulate.a = 0
		cpu_strums.scale = Vector2(0.5, 0.5)
		cpu_strums.position.x -= 15
	
	if Settings.get_setting("downscroll"):
		for strum_line in strum_lines.get_children():
			strum_line.position.y = 550
		ui.health_bar.position.y = 54
		ui.score_text.position.y = 92
	
	ui.update_score_text()
	ui.update_counter_text()
	
	# set up hold inputs
	for key in player_strums.receptors.get_child_count():
		keys_held.append(false)
	
	Main.change_rpc("Song: " + song.name + " [" + difficulty.to_upper() + "]", "Playing the Game")
	
	# start count
	begin_countdown()

func _process(delta:float):
	if not beginning_song and began_count:
		update_song_pos(delta)
		Conductor.song_position = _song_time
	else:
		Conductor.song_position += delta * 1000	
		if Conductor.song_position >= 0:
			start_song()
	
	if (player.hold_timer >= Conductor.step_crochet * player.sing_duration * 0.0011
		and not keys_held.has(true)):
		player.dance()
		player.hold_timer = 0
	
	if ui != null:
		health = clamp(health, 0, 100)
		ui.update_health_bar(health)
		update_timer_text()
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		get_tree().current_scene.add_child(Pause_Screen.instantiate())
	
	#if health <= 0:
	#	player_death()
	
	# Load Notes
	spawn_notes()
	
	# UI Icon Reset
	for i in [ui.icon_PL, ui.icon_OPP]:
		var i_lerp:float = lerpf(i.scale.x, 0.875, 0.40)
		i.scale.x = i_lerp
		i.scale.y = i_lerp
		
	ui.icon_PL.offset.x = remap(ui.icon_PL.scale.x, 1.0, 1.5, 0, 30)
	ui.icon_OPP.offset.x = -remap(ui.icon_OPP.scale.x, 1.0, 1.5, 0, 30)
	
	
	# Camera Bump Reset
	if not Settings.get_setting("reduced_motion"):
		var cam_lerp:float = lerpf(camera.zoom.x, stage.camera_zoom, 0.05)
		camera.zoom = Vector2(cam_lerp, cam_lerp)
		
		for hud in [ui, strum_lines]:
			var hud_lerp:float = lerpf(hud.scale.x, 1, 0.05)
			hud.scale = Vector2(hud_lerp, hud_lerp)
			hud_bump_reposition()


func player_death():
	get_tree().paused = true
	get_tree().current_scene.add_child(Game_Over_Screen.instantiate())

func spawn_notes():
	for note in notes_list:
		if note.step_time - Conductor.song_position > 3500:
			break
		
		var path:String = "res://game/scenes/gameplay/notes/"
		var type:String = note.type
		
		if not ResourceLoader.exists(path+type+".tscn"):
			type = "default"
		
		var new_note:Note = load(path+type+".tscn").instantiate()
		
		new_note.time = note.step_time
		new_note.direction = note.direction
		new_note.type = type
		new_note.sustain_len = note.length
		new_note.strum_line = note.strum_line
		
		strum_lines.get_child(note.strum_line).notes.add_child(new_note)
		notes_list.erase(note)

func step_hit(step:int):
	# if Conductor.ass:
	resync_vocals()

var cam_zoom:Dictionary = {
	"beat": 4,
	"hud_beat": 4,
	"bump_strength": 0.035,
	"hud_bump_strength": 0.03
}
var icon_beat_scale:float = 1.15

func beat_hit(beat:int):
	_characters_dance(beat)
	
	if not Settings.get_setting("reduced_motion"):
		for i in [ui.icon_PL, ui.icon_OPP]:
			i.scale = Vector2(icon_beat_scale, icon_beat_scale)
		
		# camera beat stuffs
		if beat % cam_zoom["beat"] == 0:
			camera.zoom += Vector2(cam_zoom["bump_strength"], cam_zoom["bump_strength"])
		
		if beat % cam_zoom["hud_beat"] == 0:
			for hud in [ui, strum_lines]:
				hud.scale += Vector2(cam_zoom["hud_bump_strength"], cam_zoom["hud_bump_strength"])
				hud_bump_reposition()
	
	for strum in strum_lines.get_children():
		for note in strum.notes.get_children():
			note.on_beat_hit(beat)

func _characters_dance(beat:int):
	var characters:Array[Character] = [player, opponent]
	if not crowd == null: characters.append(crowd)
	
	for char in characters:
		if beat % char.bopping_time == 0:
			if not char.is_singing() or not char.is_missing() \
			and char.sprite.finished_playing:
				char.dance()

# @swordcube
func hud_bump_reposition():
	for hud in [ui, strum_lines]:
		hud.offset.x = (hud.scale.x - 1.0) * -(Main.SCREEN["width"] * 0.5)
		hud.offset.y = (hud.scale.y - 1.0) * -(Main.SCREEN["height"] * 0.5)

func sect_hit(sect:int):
	if song.sections == null or song.sections[sect] == null: return
	
	if sect > song.sections.size(): sect = 0
	change_camera_position(song.sections[sect].camera_position)

func change_camera_position(whose:int):
	var char:Character = opponent
	var stage_offset:Vector2 = Vector2.ZERO
	
	match whose:
		1:
			char = player
			stage_offset = stage.player_camera
		2:
			char = crowd
			stage_offset = stage.crowd_camera
		_:
			char = opponent
			stage_offset = stage.opponent_camera
	
	var offset:Vector2 = Vector2(char.camera_offset.x + stage_offset.x, char.camera_offset.y + stage_offset.y)
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
			KEY_2:
				if Conductor.song_position >= 0:
					seek_to(inst.get_playback_position()+5)
					# make sure its synced i guess?
					resync_vocals()
			KEY_6:
				player_strums.is_cpu = !player_strums.is_cpu
				ui.cpu_text.visible = player_strums.is_cpu
			KEY_7:
				Main.switch_scene("ChartEditor")
		_note_input(key)

func _note_input(event:InputEventKey):
	var idx:int = get_input_dir(event)
	var action:String = "note_"+Tools.dirs[idx]
	
	if idx < 0 or player_strums.is_cpu:
		return
	
	keys_held[idx] = Input.is_action_pressed(action)
	
	var hit_notes:Array[Note] = []
	# cool thanks swordcube
	for note in player_strums.notes.get_children().filter(func(note:Note):
		return (note.direction == idx and !note.was_too_late \
		and note.can_be_hit and note.must_press \
		and not note.was_good_hit)
	): hit_notes.append(note)
	
	if Input.is_action_just_pressed(action): # the actual dumb thing
		if hit_notes.size() > 0:
			var hit_note = hit_notes[0]
			
			for note in hit_notes:
				if note.direction == hit_note.direction \
					and note.time == hit_note.time and not note.is_sustain:
					note.queue_free()
			
			# cool thanks swordcube
			# handles stacked notes
			if hit_notes.size() > 1:
				for i in hit_notes.size() + 1:
					var bad_note:Note = hit_notes[i]
					if absf(bad_note.time - hit_note.time) <= 5.0 \
						and hit_note.direction == idx:
							bad_note.queue_free()
					break
			
			# two loops here was kinda redundant
			note_hit(hit_note)
			
		elif not Settings.get_setting("ghost_tapping"):
			note_miss(idx)


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

var called_times:int = 0
func resync_vocals():
	var should_resync:bool = false
	if vocals.stream != null:
		var _vocals_time = vocals.get_playback_position() * 1000
		should_resync = absf(_vocals_time - _song_time) > 30
		
		if should_resync:
			called_times += 1
			# print("resyncrozining vocals "+str(called_times))
			vocals.seek(inst.get_playback_position())

# Score and Gameplay Functions
var score:int = 0
var misses:int = 0
var combo:int = 0
var health:float = 50

var rank_str:String = "N/A"
var clear_type:String = ""

func note_hit(note:Note):
	if !note.was_good_hit:
		note.was_good_hit = true
		note.note_hit(true)
		
		if vocals.stream != null: vocals.volume_db = 0
		
		player_strums.receptor_play(Tools.dirs[note.direction]+" confirm", note.direction)
		player.play_anim(get_note_anim(note), true)
		player.hold_timer = 0.0
		
		if combo < 0:
			combo = 0
		combo += 1
		# update accuracy
		judge_by_time(note)
		
		if not note.is_sustain:
			note.queue_free()

func get_note_anim(note:Note):
	var le_anim:String = "sing"+Tools.dirs[note.direction].to_upper()
	if song.sections[cur_sect].animation != "":
		le_anim += song.sections[cur_sect].animation
	return le_anim

func note_miss(direction:int):
	misses+=1
	if vocals.stream != null: vocals.volume_db = -50
	
	# decrease gameplay values
	const miss_val:int = 50
	score-=miss_val
	notes_acc-=40
	health-=miss_val / 25
	
	if combo > 0: combo = 0
	else: combo -= 1
	
	ui.display_judgement("miss")
	if combo <= -10 or combo == -1 or combo == 0:
		ui.display_combo(combo, Color8(96, 96, 96))
	
	update_gameplay_values()
	ui.update_score_text()

# Accuracy Handling
var notes_hit:int = 0
var notes_acc:float = 0
var accuracy:float:
	get:
		if notes_acc < 1: return 0.00
		else: return (notes_acc / (notes_hit + misses))

# doing presets later,
# Sick, Good, Bad, Shit
# 22.5 -- Sick if greats.
const timings = [45.0, 90.0, 135.0, 180.0]

# Name, Score, Accuracy, Timing, Health, Splashes, Image
# Splashes and Image are optional, image always defaults to name
var judgements:Array[Judgement] = [	
	Judgement.new("sick", 350, 100, timings[0], 100, true),
	# Judgement.new("great", 250, 95, timings[1], 100, false, "good"),
	Judgement.new("good", 150, 75, timings[1], 30),
	Judgement.new("bad", 50, 30, timings[2], -20),
	Judgement.new("shit", -30, -20, timings[3], -20),
]

var rankings:Dictionary = {
	"S+": 100, "S": 95, "A": 90, "B": 85, "C": 70,
	"SX": 69, "D": 68, "F": 0
}

var judgements_gotten:Dictionary = {}

func judge_by_time(note:Note):
	if notes_acc < 0: notes_acc = 0.00001
	var note_diff:float = absf(note.time - _song_time) / Conductor.song_scale
	
	var judge_id:int = 0
	var judge_name:String = "sick"
	for i in judgements.size():
		var ms_threshold:float = judgements[i].timing
		var ms_max_thre:float = 0.0
		if note_diff <= ms_threshold and ms_max_thre < ms_threshold:
			ms_max_thre = ms_threshold
			judge_name = judgements[i].name
			judge_id = i
			break
	
	score += judgements[judge_id].score
	
	notes_hit += 1
	notes_acc += maxf(0, judgements[judge_id].accuracy)
	
	health += judgements[judge_id].health / 40
	judgements_gotten[judge_name] += 1
	
	if judgements[judge_id].splash:
		player_strums.pop_splash(note.direction)
	
	update_gameplay_values()
	
	var color = Color.CYAN
	if clear_type != "MFC":
		color = null
	
	ui.display_judgement(judgements[judge_id].img, color)
	if combo >= 10 or combo == 0 or combo == 1:
		ui.display_combo(combo, color)
	
	var ms_color:Color = Color.CYAN
	match judge_name:
		"sick": ms_color = Color.CYAN
		"good": ms_color = Color.LIME
		"bad": ms_color = Color.SLATE_GRAY
		"shit": ms_color = Color.RED
	
	ui.display_milliseconds(str("%.2f" % note_diff) + "ms", ms_color)
	ui.update_score_text()

func update_ranking():
	# loop through the rankings map
	var biggest:int = 0
	for rank in rankings.keys():
		if rankings[rank] <= accuracy and rankings[rank] >= biggest:
			rank_str = rank
			biggest = accuracy

func update_clear_type():
	clear_type = ""
	
	if misses == 0:
		if judgements_gotten["sick"] > 0:
			clear_type = "MFC"
		if judgements_gotten["good"] > 0:
			clear_type = "GFC"
		if judgements_gotten["bad"] or judgements_gotten["shit"] > 0:
			clear_type = "FC"
	else:
		if misses < 10:
			clear_type = "SDCB"

func update_gameplay_values():
	update_ranking()
	ui.update_counter_text()
	update_clear_type()

var _song_time:float = 0

func update_song_pos(_delta):
	_song_time += _delta * 1000
	
	if (abs((inst.get_playback_position() * 1000) -  _song_time) > 30):
		_song_time = inst.get_playback_position() * 1000

func begin_countdown():
	began_count = true
	Conductor.song_position = -Conductor.crochet * 5;
	reset_countdown_timer()

var count_tween:Tween
var count_timer:SceneTreeTimer
var count_tick:int = 0

func process_countdown(reset:bool = false):
	if count_tween != null:
		count_tween.stop()
	
	if reset:
		count_tick = 0
	
	var sounds:Array[String] = ["intro3", "intro2", "intro1", "introGo"]
	
	create_countdown_sprite()
	SoundGroup.play_sound(Paths.sound("game/base/" + sounds[count_tick]))
	count_tick += 1
	
	_characters_dance(count_tick)
	
	if count_tick < 4:
		reset_countdown_timer()

var scaled_crochet:float = (Conductor.crochet / 1000) / Conductor.song_scale

func reset_countdown_timer():
	count_timer = get_tree().create_timer(scaled_crochet, false)
	count_timer.timeout.connect(process_countdown)

func create_countdown_sprite():
	var countdown_sprite = $UI/Countdown.get_child(count_tick)
	# countdown_sprite.modulate.a = 1
	
	# tween in
	count_tween = create_tween().set_ease(Tween.EASE_IN)
	count_tween.tween_property(countdown_sprite, "modulate:a", 1, 0.005)
	
	# tween out
	count_tween = create_tween().set_ease(Tween.EASE_OUT)
	count_tween.tween_property(countdown_sprite, "modulate:a", 0, scaled_crochet)
