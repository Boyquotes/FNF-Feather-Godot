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
@onready var strum_lines:CanvasLayer = $UI/Strumlines

@onready var player_strums:StrumLine = $UI/Strumlines/player_Strums
@onready var cpu_strums:StrumLine = $UI/Strumlines/cpu_Strums

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
		if i is StrumLine:
			i._generate_receptors()
	
	if Settings.get_setting("center_notes"):
		# cpu_strums.modulate.a = 0
		cpu_strums.scale = Vector2(0.5, 0.5)
		cpu_strums.position.x -= 25
	
	if Settings.get_setting("downscroll"):
		for strum_line in strum_lines.get_children():
			strum_line.position.y = 550
		ui.health_bar.position.y = 54
		ui.score_text.position.y = 92
	
	# set up judgement amounts
	for i in judgements.size():
		var judge = judgements[i].name
		judgements_gotten[judge] = 0
	
	
	if Settings.get("hud_judgements"):
		objects.remove_child(judgement_group)
		objects.remove_child(combo_group)
		
		ui.add_child(judgement_group)
		ui.add_child(combo_group)
	
	if Settings.get_setting("stage_darkness") > 0:
		var darkness:Sprite2D = Sprite2D.new()
		darkness.draw_rect(Rect2(0, 0, 1280, 720), -1)
		darkness.modulate.a = Settings.get_setting("stage_darkness") * 0.01
		ui.add_child(darkness)
	
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
	
	if health <= 0:
		player_death()
	
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
	
	for strum in strum_lines.get_children():
		for note in strum.notes.get_children():
			note.on_beat_hit(beat)

# @swordcube
func hud_bump_reposition():
	for hud in [ui, strum_lines]:
		hud.offset.x = (hud.scale.x - 1.0) * -(Main.SCREEN["width"] * 0.5)
		hud.offset.y = (hud.scale.y - 1.0) * -(Main.SCREEN["height"] * 0.5)

func sect_hit(sect:int):
	if sect > song.sections.size(): sect = 0
	if song.sections[sect] == null: return
	change_camera_position(song.sections[sect].camera_position)

func change_camera_position(whose:int):
	var char:Character = opponent
	match whose:
		1: char = player
		2: char = crowd
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
	
	var can_be_hit:Array[bool] = []
	for key in player_strums.receptors.get_child_count():
		can_be_hit.append(false)
	
	if Input.is_action_just_pressed(action): # the actual dumb thing
		if hit_notes.size() > 0:
			for i in can_be_hit.size():
				can_be_hit[i] = true
			
			var hit_note = hit_notes[0]
			
			# cool thanks swordcube
			# handles stacked notes
			if hit_notes.size() > 1:
				for i in hit_notes.size():
					var bad_note:Note = hit_notes[i]
					if absf(bad_note.time - hit_note.time) <= 5.0 \
						and hit_note.direction == idx:
							bad_note.queue_free()
					else:
						can_be_hit[hit_note.direction] = false
					break
			
			# two loops here was kinda redundant
			if can_be_hit[hit_note.direction]:
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
		
		# update accuracy
		combo += 1
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
	health-=miss_val / 50
	combo = 0
	
	update_gameplay_values()
	ui.update_score_text()

# Accuracy Handling
var notes_hit:int = 0
var notes_acc:float = 0
var accuracy:float:
	get:
		if notes_acc < 1: return 0.00
		else: return (notes_acc / notes_hit)

# Name, Score, Accuracy, Timing, Health, Splashes, Image
# Splashes and Image are optional, image always defaults to name
var judgements:Array[Judgement] = [	
	Judgement.new("sick", 350, 100, 22.5, 100, true),
	Judgement.new("great", 250, 95, 45.0, 100, false, "good"),
	Judgement.new("good", 150, 75, 90.0, 30),
	Judgement.new("bad", 50, 30, 135.0, -20),
	Judgement.new("shit", -30, -20, 180.0, -20)
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
	
	health += judgements[judge_id].health / 50
	judgements_gotten[judge_name] += 1
	
	if judgements[judge_id].splash:
		player_strums.pop_splash(note.direction)
	
	display_judgement(judgements[judge_id])
	display_combo()
	
	update_gameplay_values()
	ui.update_score_text()

func get_clear_type():
	var clear_colors:Dictionary = {
		"MFC": "CYAN",
		"GFC": "SPRING_GREEN",
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
		if judgements_gotten["great"] or judgements_gotten["good"] > 0:
			clear_type = "GFC"
		if judgements_gotten["bad"] or judgements_gotten["shit"] > 0:
			clear_type = "FC"
	elif misses < 10:
		clear_type = "SDCB"

func update_gameplay_values():
	update_ranking()
	ui.update_counter_text()
	update_clear_type()

# Other Functions
var show_judgements:bool = true
var show_combo_numbers:bool = true
var show_combo_sprite:bool = false

func display_judgement(judge:Judgement):
	if not show_judgements:
		return
	
	if not Settings.get_setting("combo_stacking"):
		# kill other judgements if they exist
		for j in judgement_group.get_children():
			j.queue_free()
	
	var judgement:FeatherSprite2D = FeatherSprite2D.new()
	judgement.texture = load(Paths.image("ui/base/ratings/"+judge.img))
	judgement_group.add_child(judgement)
	
	if judge.name == "great":
		judgement.modulate = Color.SPRING_GREEN
	
	judgement.acceleration.y = 550
	judgement.velocity.y = -randi_range(140, 175)
	judgement.velocity.x = -randi_range(0, 10)
	
	judgement.scale = Vector2(0.6, 0.6)
	get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
	.tween_property(judgement, "scale", Vector2(0.7, 0.7), 0.1)
	
	get_tree().create_tween().tween_property(judgement, "modulate:a", 0, (Conductor.step_crochet) / 1000) \
	.set_delay((Conductor.crochet + Conductor.step_crochet * 2) / 1000) \
	.finished.connect(func(): judgement.queue_free())

func display_combo():
	if not Settings.get_setting("combo_stacking"):
		# kill other combo objects if they exist
		for c in combo_group.get_children():
			c.queue_free()
	
	if not show_combo_numbers:
		return
	
	# split combo in half
	var numbers:PackedStringArray = str(combo).lpad(3, "0").split("")
	
	var last_judgement = judgement_group.get_child(judgement_group.get_child_count() - 1)
	
	for i in numbers.size():
		var combo:FeatherSprite2D = FeatherSprite2D.new()
		combo.texture = load(Paths.image("ui/base/combo/num"+numbers[i]))
		combo.position.x = (45 * i) + last_judgement.position.x + 50
		combo.position.y = last_judgement.position.y + 130
		combo_group.add_child(combo)
		
		combo.acceleration.y = randi_range(100, 200)
		combo.velocity.y = -randi_range(140, 160)
		combo.velocity.x = -randi_range(-5, 5)
		
		combo.scale = Vector2(0.63, 0.63)
		get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC) \
		.tween_property(combo, "scale", Vector2(0.53, 0.53), 0.1)
		
		get_tree().create_tween() \
		.tween_property(combo, "modulate:a", 0, (Conductor.step_crochet * 2) / 1000) \
		.set_delay((Conductor.crochet) / 1000) \
		.finished.connect(func(): combo.queue_free())
		
		last_num = combo
	
	display_combo_sprite()

var last_num:FeatherSprite2D
func display_combo_sprite():
	if not show_combo_sprite:
		return
	
	var combo_spr:FeatherSprite2D = FeatherSprite2D.new()
	combo_spr.texture = load(Paths.image("ui/base/ratings/combo"))
	combo_spr.scale = Vector2(0.7, 0.7)
	combo_spr.position.y += 75
	combo_group.add_child(combo_spr)
	
	combo_spr.acceleration.y = 600
	combo_spr.velocity.y = -150
	combo_spr.velocity.x = randi_range(1, 10)
	
	get_tree().create_tween() \
	.tween_property(combo_spr, "modulate:a", 0, (Conductor.step_crochet) / 1000) \
	.set_delay((Conductor.crochet + Conductor.step_crochet * 2) / 1000) \
	.finished.connect(func(): combo_spr.queue_free())

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
