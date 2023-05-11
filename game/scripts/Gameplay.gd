extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER}

const Pause_Screen = preload("res://game/gameplay/subScenes/PauseScreen.tscn")
const Game_Over_Screen = preload("res://game/gameplay/subScenes/GameOver.tscn")

var note_paths:Dictionary = {
	"default": "res://game/gameplay/notes/Default.tscn"
}

var note_scenes:Dictionary = {
	"default": preload("res://game/gameplay/notes/Default.tscn").instantiate()
}

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

@onready var judgement_group:CanvasGroup = $"Judgement Group"
@onready var combo_group:CanvasGroup = $"Combo Group"

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
	
	# set up judgement amounts
	for judgement in judgements.keys():
		judgements_gotten[judgement] = 0
	update_score_text()
	update_counter_text()

	$Darkness.modulate.a = Settings.get_setting("stage_darkness") * 0.01
	
	# set up hold inputs
	for key in player_strums.receptors.get_child_count():
		keys_held.append(false)
	
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
	
	if vocals.stream != null and vocals.get_playback_position()*1000 <= _song_time - 25.5:
		vocals.seek(inst.get_playback_position())
	
	if (player.hold_timer >= Conductor.step_crochet * player.sing_duration * 0.0011
		and not keys_held.has(true)):
		player.dance()
		player.hold_timer = 0
	
	if ui != null:
		health = clamp(health, 0, 100)
		ui.update_health_bar(health)
		update_timer_text()
	
	if Input.is_action_just_pressed("pause"):
		get_tree().current_scene.add_child(Pause_Screen.instantiate())
		get_tree().paused = true
	
	if health <= 0:
		player_death()
	
	# Load Notes
	spawn_notes()
	
	# UI Icon Reset
	for i in [ui.icon_PL, ui.icon_OPP]:
		var i_lerp:float = lerpf(i.scale.x, 0.875, 0.40)
		i.scale.x = i_lerp
		i.scale.y = i_lerp
	
	# Camera Bump Reset
	var cam_lerp:float = lerpf(camera.zoom.x, stage.camera_zoom, 0.05)
	camera.zoom = Vector2(cam_lerp, cam_lerp)
	
	for hud in [ui, strum_lines]:
		var hud_lerp:float = lerpf(hud.scale.x, 1, 0.05)
		hud.scale = Vector2(hud_lerp, hud_lerp)
		hud_bump_reposition()
	
	if Input.is_action_just_pressed("reset"):
		health = 0

func player_death():
	get_tree().paused = true
	get_tree().current_scene.add_child(Game_Over_Screen.instantiate())

func spawn_notes():
	for note in notes_list:
		if note.step_time - Conductor.song_position > 3500:
			break
		
		var queued_type:String = note.type
		if not note_paths.has(note.type):
			# print("note of type \""+note.type+"\" can't be spawned")
			queued_type = "default"
		
		var queued_note:Note = Note.new(note.step_time, note.direction, queued_type, note.length)
		queued_note.position = Vector2(-9999, -9999)
		# queued_note.time = note.step_time
		# queued_note.direction = note.direction
		# queued_note.type = queued_type
		# queued_note.sustain_len = note.length
		queued_note.strum_line = note.strum_line
		
		strum_lines.get_child(note.strum_line).add_note(queued_note)
		notes_list.erase(note)

var cam_zoom:Dictionary = {
	"beat": 4,
	"hud_beat": 4,
	"bump_strength": 0.035,
	"hud_bump_strength": 0.03
}
var icon_beat_scale:float = 1.15

func beat_hit(beat:int):
	var characters:Array[Character] = [player, opponent]
	for char in characters:
		if beat % char.bopping_time == 0:
			if (not char.is_singing() or
				char.is_singing() and char.sprite.finished_playing and not char.is_player):
				char.dance()
	
	for i in [ui.icon_PL, ui.icon_OPP]:
		i.scale = Vector2(icon_beat_scale, icon_beat_scale)
	
	# camera beat stuffs
	if not Settings.get_setting("reduced_motion"):
		if beat % cam_zoom["beat"] == 0:
			camera.zoom += Vector2(cam_zoom["bump_strength"], cam_zoom["bump_strength"])
		
		if beat % cam_zoom["hud_beat"] == 0:
			for hud in [ui, strum_lines]:
				hud.scale += Vector2(cam_zoom["hud_bump_strength"], cam_zoom["hud_bump_strength"])
				hud_bump_reposition()

# @swordcube
func hud_bump_reposition():
	for hud in [ui, strum_lines]:
		hud.offset.x = (hud.scale.x - 1.0) * -(Main.SCREEN["width"] * 0.5)
		hud.offset.y = (hud.scale.y - 1.0) * -(Main.SCREEN["height"] * 0.5)

func sect_hit(sect:int):
	if sect > song.sections.size():
		sect = 0
	
	if song.sections[sect] == null: return
	change_camera_position(song.sections[sect].camera_position)

func step_hit(step:int):
	match song_name.to_lower():
		"lunar-odyssey":
			if step == 623:
				process_countdown(true)
				cam_zoom["beat"] = 1
				cam_zoom["hud_beat"] = 2

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
			KEY_2:
				if Conductor.song_position >= 0:
					seek_to(inst.get_playback_position()+5)
					# make sure its synced i guess?
					vocals.seek(inst.get_playback_position())
			KEY_6:
				player_strums.is_cpu = !player_strums.is_cpu
				ui.cpu_text.visible = player_strums.is_cpu
			KEY_7:
				Main.switch_scene("ChartEditor")
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

var rank_str:String = "N/A"
var clear_type:String = ""

const score_div:String = " • "

func update_score_text():
	var actual_acc:float = accuracy * 100 / 100
	
	var tmp_txt:String = "SCORE: ["+str(score)+"]"
	tmp_txt+=score_div+"ACCURACY: ["+str("%.2f" % actual_acc)+"%]"
	if get_clear_type() != "":
		tmp_txt+=score_div+"RANK: ["+get_clear_type()+" - "+rank_str+"]"
	else:
		tmp_txt+=score_div+"RANK: ["+rank_str+"]"
	
	# Use "bbcode_text" instead of "text"
	ui.score_text.bbcode_text = tmp_txt
	
	var score_width:float = ui.score_text.get_viewport_rect().position.x
	ui.score_text.position.x = ((Main.SCREEN["width"] * 0.5) - (ui.score_text.get_content_width() / 2.0))

func update_counter_text():
	if ui.counter == null:
		return
	
	var counter_div:String = '\n'
	if Settings.get_setting("judgement_counter") == "horizontal":
		counter_div = score_div
	
	var tmp_txt:String = ""
	for i in judgements_gotten:
		tmp_txt += i.to_pascal_case()+': '+str(judgements_gotten[i])+counter_div
	tmp_txt += 'Miss: '+str(misses)
	ui.counter.text = tmp_txt

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
		judge_by_time(note)
		player_strums.remove_note(note)

func note_miss(direction:int):
	misses+=1
	if vocals.stream != null: vocals.volume_db = -50
	
	# decrease gameplay values
	const miss_val:int = 50
	score-=miss_val
	notes_acc-=40
	health-=miss_val / 50
	combo = 0
	
	update_gameplay_values()
	update_score_text()

# Accuracy Handling
var notes_hit:int = 0
var notes_acc:float = 0
var accuracy:float:
	get:
		if notes_acc < 1: return 0.00
		else: return (notes_acc / notes_hit)

# Dictionary Order:
# Score (Integer),Accuracy Gain (Int), Timing (Float), Health Gain (Integer)
var judgements:Dictionary = {
	"sick": [350, 100, 35.0, 100],
	"good": [150, 75, 50.0, 30],
	"bad": [50, 30, 120.0, -20],
	"shit": [-30, -20, 180.0, -20]
}

var rankings:Dictionary = {
	"S+": 100, "S": 95, "A": 90, "B": 85, "C": 75,
	"SX": 69, "D": 70, "F": 0
}

var judgements_gotten:Dictionary = {}

func judge_by_time(note:Note):
	if notes_acc < 0: notes_acc = 0.00001
	var note_diff:float = absf(Conductor.song_position - note.time)
	
	var judge_result:String = "sick"
	for judge in judgements.keys():
		var ms_threshold:float = judgements[judge][2]
		var ms_max_thre:float = 0.0
		if note_diff > ms_threshold and ms_max_thre < ms_threshold:
			judge_result = judge
			ms_max_thre = ms_threshold
	
	score += judgements[judge_result][0]
	notes_acc += maxf(0, judgements[judge_result][1])
	health += judgements[judge_result][3] / 50
	judgements_gotten[judge_result] += 1
	
	if judge_result == "sick":
		player_strums.pop_splash(note.direction)
	
	display_judgement(judge_result)
	display_combo()
	
	update_gameplay_values()
	update_score_text()

func get_clear_type():
	var clear_colors:Dictionary = {
		"MFC": "CYAN",
		"GFC": "LIME",
		"FC": "LIGHT_SLATE_GRAY",
		"SDCB": "CRIMSON"
	}
	
	# overenginered bullshit
	var markup:String = ""
	var markup_end:String = ""
	if clear_colors.has(clear_type):
		markup = "[color="+clear_colors[clear_type]+"]"
		markup_end = "[/color]"
	
	# return colored clear type if it exists on the clear_colors colors dictio
	var colored_clear:String = markup+clear_type+markup_end
	return colored_clear if markup != "" else clear_type if clear_type != "" else ""

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
		if judgements_gotten["sick"] > 0: clear_type = "MFC"
		if judgements_gotten["good"] > 0: clear_type = "GFC"
		if judgements_gotten["bad"] or judgements_gotten["shit"] > 0:
			clear_type = "FC"
	elif misses < 10:
		clear_type = "SDCB"

func update_gameplay_values():
	update_ranking()
	update_counter_text()
	update_clear_type()

# Other Functions
func display_judgement(judge:String):
	var judgement:FeatherSprite2D = FeatherSprite2D.new()
	judgement.texture = load(Paths.image("ui/base/ratings/"+judge))
	judgement.scale = Vector2(0.8, 0.8)
	judgement_group.add_child(judgement)
	
	judgement.acceleration.y = 350
	judgement.velocity.y = -randi_range(140, 175)
	judgement.velocity.x = -randi_range(0, 10)
	
	get_tree().create_tween() \
	.tween_property(judgement, "modulate:a", 0, (Conductor.step_crochet) / 1000) \
	.set_delay((Conductor.crochet + Conductor.step_crochet * 2) / 1000) \
	.finished.connect(func(): judgement.queue_free())

func display_combo():
	# split combo in half
	var numbers:PackedStringArray = str(combo).split("")
	for i in numbers.size():
		var combo:FeatherSprite2D = FeatherSprite2D.new()
		combo.texture = load(Paths.image("ui/base/combo/num"+numbers[i]))
		combo.scale = Vector2(0.6, 0.6)
		combo.position.x += (55 * i)
		combo_group.add_child(combo)
		
		combo.acceleration.y = randi_range(100, 200)
		combo.velocity.y = -randi_range(140, 160)
		combo.velocity.x = -randi_range(-5, 5)
		
		get_tree().create_tween() \
		.tween_property(combo, "modulate:a", 0, (Conductor.step_crochet * 2) / 1000) \
		.set_delay((Conductor.crochet) / 1000) \
		.finished.connect(func(): combo.queue_free())
	
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
