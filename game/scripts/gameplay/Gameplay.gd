class_name Gameplay extends MusicBeatNode2D

const PAUSE_SCREEN = preload("res://game/scenes/gameplay/subScenes/PauseScreen.tscn")
const DEFAULT_NOTE = preload("res://game/scenes/gameplay/notes/default.tscn")

var SONG:Chart
var song_time:float = 0.0
var note_list:Array[ChartNote] = []
var event_list:Array[ChartEvent] = []

@onready var camera:Camera2D = $Game_Camera
@onready var inst:AudioStreamPlayer = $Inst
@onready var voices:AudioStreamPlayer = $Voices


@onready var ui:CanvasLayer = $UI
@onready var score_text:Label = $UI/Health_Bar/Score_Text
@onready var health_bar:TextureProgressBar = $UI/Health_Bar
@onready var icon_P1:FFSprite2D = $UI/Health_Bar/Player_Icon
@onready var icon_P2:FFSprite2D = $UI/Health_Bar/Cpu_Icon

@onready var strum_lines:Node2D = $UI/Strum_Lines
@onready var player_strums:StrumLine = $UI/Strum_Lines/Player
@onready var cpu_strums:StrumLine = $UI/Strum_Lines/CPU

@onready var judgement_group:CanvasGroup = $Judgement_Group
@onready var combo_group:CanvasGroup = $Combo_Group


@onready var player:Character = $Player
@onready var cpu:Character = $CPU
@onready var stage:Stage = $Stage

var valid_score:bool = true
var script_stack:Array[FFScript] = []


func _init():
	super._init()
	
	SONG = Chart.load_chart(Game.gameplay_song["folder"], Game.gameplay_song["difficulty"])
	if not SONG == null:
		note_list = SONG.notes
		event_list = SONG.events
		Game.CURRENT_SONG = SONG


func load_scripts_at(path:String):
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".gd") or file.ends_with(".gdscript"):
			var script:FFScript = FFScript.load_script(path + "/" + file, self)
			if not script_stack.has(script):
				script_stack.append(script)


func _ready():
	load_scripts_at("res://assets/scripts")
	load_scripts_at("res://assets/scripts/" + SONG.name)
	
	trigger_event(event_list[0])
	
	for i in script_stack.size():
		script_stack[i]._ready()
	
	health_bar.tint_progress = player.health_color
	health_bar.tint_under = cpu.health_color
	health_bar.position.y = 63 if Settings.get_setting("downscroll") else 630
	
	icon_P1.texture = load("res://assets/images/icons/" + player.health_icon + ".png")
	icon_P2.texture = load("res://assets/images/icons/" + cpu.health_icon + ".png")
	
	for strum_line in strum_lines.get_children():
		strum_line.position.y = 625 if Settings.get_setting("downscroll") else 95
	
	if Settings.get_setting("centered_receptors"):
		player_strums.position.x = Game.SCREEN["width"] / 2.0
		cpu_strums.scale = Vector2(0.5, 0.5)
		cpu_strums.position.x += 100
		cpu_strums.modulate.a = 0.6
		
		for i in [2, 3]:
			cpu_strums.receptors.get_child(i).position.x += player_strums.position.x + 255
	
	cpu_strums.visible = Settings.get_setting("cpu_receptors")
	
	# Setup the Game Camera
	camera.zoom = Vector2(stage.camera_zoom, stage.camera_zoom)
	camera.position_smoothing_speed = 3 * stage.camera_speed * Conductor.pitch_scale
	camera.position_smoothing_enabled = true
	
	# And the Audio Tracks 
	inst.stream = load("res://assets/songs/" + SONG.name + "/Inst.ogg")
	inst.stream.loop = false
	inst.pitch_scale = Settings.get_setting("song_pitch")
	
	if ResourceLoader.exists("res://assets/songs/" + SONG.name + "/Voices.ogg"):
		voices.stream = load("res://assets/songs/" + SONG.name + "/Voices.ogg")
		voices.stream.loop = false
		voices.pitch_scale = inst.pitch_scale
	
	inst.finished.connect(end_song)
	
	# Setup Keys for Inputs later
	for key in player_strums.receptors.get_child_count():
		keys_held.append(false)
	
	for i in judgements.size():
		judgements_gotten[judgements[i].name] = 0
	
	update_score_text()
	
	# Start Countdown
	begin_countdown()
	
	for i in script_stack.size():
		script_stack[i]._post_ready()


var starting_song:bool = true
var began_count:bool = false

var count_tween:Tween
var count_timer:SceneTreeTimer
var count_tick:int = 0


func begin_countdown():
	Conductor.position = -(Conductor.crochet * 5.5)
	
	for i in script_stack.size():
		script_stack[i].begin_countdown()
	
	began_count = true
	reset_countdown_timer()


func process_countdown(reset:bool = false):
	for i in script_stack.size():
		script_stack[i].on_countdown(count_tick)
	
	if not count_tween == null:
		count_tween.stop()
	
	if reset:
		count_tick = 0
	
	var intro_images:Array[String] = ["prepare", "ready", "set", "go"]
	var intro_sounds:Array[String] = ["intro3", "intro2", "intro1", "introGo"]
	
	var countdown_sprite:FFSprite2D = $UI/Countdown_Template.duplicate()
	countdown_sprite.texture = load("res://assets/images/ui/countdown/" + SONG.song_style + "/" + intro_images[count_tick] + ".png")
	countdown_sprite.visible = true
	countdown_sprite.modulate.a = 1.0
	if SONG.song_style == "pixel":
		countdown_sprite.scale = Vector2(6, 6)
		countdown_sprite.texture_filter = TEXTURE_FILTER_NEAREST
	ui.add_child(countdown_sprite)
	
	# tween out
	var scaled_crochet:float = 0.85 * (Conductor.crochet / 1000) / Conductor.pitch_scale
	
	count_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	count_tween.tween_property(countdown_sprite, "modulate:a", 0.0, scaled_crochet) \
	.finished.connect(countdown_sprite.queue_free)
	
	SoundHelper.play_sound("res://assets/sounds/game/" + SONG.song_style + "/" + intro_sounds[count_tick] + ".ogg")
	count_tick += 1
	
	_characters_dance(count_tick)
	
	if count_tick < 4:
		reset_countdown_timer()


func reset_countdown_timer():
	var scaled_crochet:float = (Conductor.crochet / 1000) / Conductor.pitch_scale
	count_timer = get_tree().create_timer(scaled_crochet, false)
	count_timer.timeout.connect(process_countdown)


func start_song():
	starting_song = false
	
	inst.play(0.0)
	if not voices.stream == null:
		voices.play(0.0)


var health_bar_width:float:
	get: return health_bar.texture_progress.get_size().x


func _process(delta:float):
	for i in script_stack.size():
		script_stack[i]._process(delta)
	
	if starting_song and began_count:
		Conductor.position += ((delta * 1000.0) * Conductor.pitch_scale)
		if Conductor.position >= 0:
			start_song()
	else:
		if (absf((inst.get_playback_position() * 1000.0) -  Conductor.position) > 8.0):
			Conductor.position = inst.get_playback_position() * 1000.0
	
	
	if (player.hold_timer >= Conductor.step_crochet * player.sing_duration * 0.0011
		and not keys_held.has(true)):
		player.dance()
		player.hold_timer = 0.0
	
	# Update the UI elements and such
	for i in [icon_P1, icon_P2]:
		var i_lerp:float = lerpf(i.scale.x, 0.9, 0.15)
		i.scale.x = i_lerp
		i.scale.y = i_lerp
	
	health = clampi(health, 0, 100)
	health_bar.value = clampi(health, 0, 100)
	
	icon_P1.position.x = health_bar.position.x + ((health_bar_width*(1 - health_bar.value / 100)) - icon_P1.width)
	icon_P2.position.x = health_bar.position.x + ((health_bar_width*(1 - health_bar.value / 100)) - icon_P2.width) - 80

	icon_P1.frame = 1 if health_bar.value < 20 else 0
	icon_P2.frame = 1 if health_bar.value > 80 else 0
	
	var cam_lerp:float = lerpf(camera.zoom.x, stage.camera_zoom, 0.05)
	camera.zoom = Vector2(cam_lerp, cam_lerp)
	
	var hud_lerp:float = lerpf(ui.scale.x, 1, 0.05)
	ui.scale = Vector2(hud_lerp, hud_lerp)
	hud_bump_reposition()
	
	if Input.is_action_just_pressed("ui_pause"):
		var pause_menu = PAUSE_SCREEN.instantiate()
		get_tree().paused = true
		ui.add_child(pause_menu)
	
	
	if event_list.size() > 5:
		for i in event_list.size():
			if Conductor.position <= event_list[i].time:
				break
			
			trigger_event(event_list[i])
			event_list.erase(event_list[i])
	
	
	for note in note_list:
		var note_speed:float = SONG.speed if Settings.get_setting("note_speed") <= 0 else Settings.get_setting("note_speed")
		if note.time < Conductor.position + (2500 / (note_speed / Conductor.pitch_scale)):
			break
		
		
		var new_note:Note = DEFAULT_NOTE.instantiate()
		new_note.time = note.time - Conductor.note_offset
		new_note.direction = note.direction
		new_note.type = note.type
		
		new_note.speed = note_speed
		
		new_note.hold_length = note.length
		new_note.strum_line = note.strum_line
		new_note.must_press = new_note.strum_line == 1
		
		for i in script_stack.size():
			script_stack[i].note_spawn(new_note)
		
		strum_lines.get_child(note.strum_line).notes.add_child(new_note)
		note_list.erase(note)
	
	for i in script_stack.size():
		script_stack[i]._post_process(delta)



var score_separator:String = " ~ "


func update_score_text():
	var accuracy_string:String = " - " + "%.2f" % (accuracy * 100 / 100) + "%"
	
	var rank_string:String = rank_name + accuracy_string
	if not clear_rank == "":
		rank_string = "(" + clear_rank + ") " + rank_name + accuracy_string
	
	score_text.text = "Score: " + str(score) + score_separator + "Misses: " + str(misses) + \
	score_separator + "Grade: " + rank_string

var cam_zoom:Dictionary = {
	"beat": 4,
	"hud_beat": 4,
	"bump_strength": 0.035,
	"hud_bump_strength": 0.03
}
var icon_beat_scale:float = 0.25

func on_beat(beat:int):
	for i in script_stack.size():
		script_stack[i].on_beat(beat)
	
	_characters_dance(beat)
	
	for i in [icon_P1, icon_P2]:
		i.scale = Vector2(i.scale.x + icon_beat_scale, i.scale.y + icon_beat_scale)
	
	# camera beat stuffs
	if beat % cam_zoom["beat"] == 0:
		camera.zoom += Vector2(cam_zoom["bump_strength"], cam_zoom["bump_strength"])
	
	if beat % cam_zoom["hud_beat"] == 0:
		ui.scale += Vector2(cam_zoom["hud_bump_strength"], cam_zoom["hud_bump_strength"])
		hud_bump_reposition()

# @swordcube
func hud_bump_reposition():
	ui.offset.x = (ui.scale.x - 1.0) * -(Game.SCREEN["width"] * 0.5)
	ui.offset.y = (ui.scale.y - 1.0) * -(Game.SCREEN["height"] * 0.5)

func _characters_dance(beat:int):
	var characters:Array[Character] = [player, cpu]
	# if not spectator == null: characters.append(spectator)
	
	for char in characters:
		if beat % char.headbop_beat == 0:
			if not char.is_singing() or not char.is_missing() \
			and char.finished_anim:
				char.dance()


func on_step(step:int):
	for i in script_stack.size():
		script_stack[i].on_step(step)


func on_bar(bar:int):
	for i in script_stack.size():
		script_stack[i].on_bar(bar)


func trigger_event(event:ChartEvent):
	match event.name:
		"BPM Change":
			if not event.arguments[0] == null:
				Conductor.change_bpm(event.arguments[0])
			
		"Camera Pan":
			var arg = event.arguments[0]
			
			var char:Character = cpu
			var stage_offset:Vector2 = stage.cpu_camera
			
			match arg:
				"player":
					char = player
					stage_offset = stage.player_camera
				"cpu":
					char = cpu
					stage_offset = stage.cpu_camera
			
			var offset:Vector2 = Vector2(char.camera_offset.x + stage_offset.x, char.camera_offset.y + stage_offset.y)
			camera.position = Vector2(char.get_camera_midpoint().x + offset.x, char.get_camera_midpoint().y + offset.y)


func end_song():
	inst.stop()
	if not voices.stream == null:
		voices.stop()
	
	if valid_score:
		Game.save_song_score(Game.gameplay_song["folder"], Game.gameplay_song["difficulty"], score)
	
	match Game.gameplay_mode:
		#0: Game.switch_scene("scenes/menus/MainMenu")
		_: Game.switch_scene("scenes/menus/FreeplayMenu")
		#2: Game.switch_scene("scenes/editors/ChartEditor")



var keys_held:Array[bool] = []


func _input(event:InputEvent):
	if event is InputEventKey:
		if event.pressed: match event.keycode:
			KEY_6:
				player_strums.is_cpu = not player_strums.is_cpu
				$UI/Autoplay_Text.visible = player_strums.is_cpu
				valid_score = false
			KEY_7: Game.switch_scene("XML Converter", false, "converters")
			
		var dir:int = get_input_dir(event)
		if dir < 0 or player_strums.is_cpu:
			return
		
		keys_held[dir] = Input.is_action_pressed("note_" + Game.note_dirs[dir].to_lower())
		
		var receptor:Receptor = player_strums.receptors.get_child(dir)
		
		var hit_notes:Array[Note] = []
		# cool thanks swordcube
		for note in player_strums.notes.get_children().filter(func(note:Note):
			return (note.direction == dir and not note.was_too_late \
			and note.can_be_hit and note.must_press \
			and not note.was_good_hit)
		): hit_notes.append(note)
		
		# the actual dumb thing
		if Input.is_action_just_pressed("note_" + \
			Game.note_dirs[dir].to_lower()):
			
			if hit_notes.size() > 0:
				var hit_note = hit_notes[0]
				
				# handles stacked notes
				if hit_notes.size() > 1:
					
					for i in hit_notes.size():
						if i == 0: continue
						
						var bad_note:Note = hit_notes[i]
						if absf(bad_note.time - hit_note.time) <= 5.0 \
							and hit_note.direction == dir:
								bad_note.queue_free()
						break
				
				note_hit(hit_note)
				receptor.play_anim(Game.note_dirs[dir].to_lower() + " confirm")
			else:
				if not Settings.get_setting("ghost_tapping"):
					ghost_miss(dir)


func get_input_dir(e:InputEventKey):
	# todo: find a way of getting the input keycode without
	# looping thru note directions array
	var stored_number:int = -1
	
	for i in Game.note_dirs.size():
		var a:String = "note_" + Game.note_dirs[i].to_lower()
		if e.is_action_pressed(a) or e.is_action_released(a):
			stored_number = i
			break
	
	return stored_number


var judgements:Array[Judgement] = [
	# Name, Score Gain, Health Gain/Loss Accuracy Modifier, Note Splashes, Image
	Judgement.new("sick", 300, 100, 100.0, true),
	Judgement.new("good", 180, 80, 80.0, false),
	Judgement.new("bad", 50, 30, 60.0, false),
	Judgement.new("shit", -45, -20, 25.0, false)
]

var score:int = 0
var misses:int = 0

var health:float = 50
var combo:int = 0

var notes_accuracy:float = 0.00
var total_notes_hit:int = 0
var accuracy:float = 0.00:
	get:
		if notes_accuracy <= 0.00: return 0.00
		return (notes_accuracy / (total_notes_hit + misses))


var judgements_gotten:Dictionary = {}

var score_color:Tween


func note_hit(note:Note):
	if note.was_good_hit: return
	note.was_good_hit = true
	
	for i in script_stack.size():
		script_stack[i].note_hit(note)
	
	player.play_anim("sing" + Game.note_dirs[note.direction].to_upper(), true)
	player.hold_timer = 0.0
	
	if not voices.stream == null:
		voices.volume_db = 0
	
	var judging_allowed:bool = not player_strums.is_cpu
	
	if judging_allowed:
		var note_ms:float = absf(note.time - Conductor.position) * Conductor.pitch_scale
		var note_judgement:Judgement
		
		for i in judgements.size():
			if note_ms > judgements[i].timing:
				continue
			else:
				note_judgement = judgements[i]
				break
		
		score += note_judgement.score
		if combo < 0:
			combo = 0
		combo += 1
		health += note_judgement.health / 50
		
		# Accuracy
		total_notes_hit += 1
		notes_accuracy += maxf(0, note_judgement.accuracy)
		judgements_gotten[note_judgement.name] += 1
		
		if note_judgement.name == "sick" or note.splash:
			player_strums.pop_splash(note.direction)
		
		display_judgement(note_judgement.img)
		if combo >= 10 or combo == 0 or combo == 1:
			display_combo()
		
		var judgement_color:Color
		match note_judgement.name:
			"sick": judgement_color = Color.CYAN
			"good": judgement_color = Color.LIME
			"bad": judgement_color = Color.DARK_SLATE_GRAY
			"shit": judgement_color = Color.DARK_RED
		
		score_text.modulate = judgement_color
		if not score_color == null:
			score_color.stop()
		
		score_color = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		score_color.tween_property(score_text, "modulate", Color.WHITE, 0.35)
		
		update_ranking()
		update_score_text()
	
	if not note.is_hold:
		note.queue_free()


func cpu_note_hit(note:Note, strum_line:StrumLine):
	var receptor = strum_line.receptors.get_child(note.direction)
	
	var char:Character = player if note.must_press else cpu
	char.play_anim("sing" + Game.note_dirs[note.direction].to_upper(), true)
	char.hold_timer = 0.0
	
	if not voices.stream == null:
		voices.volume_db = 0.0

	note.was_good_hit = true
	if not note.is_hold:
		note.queue_free()


func note_miss(note:Note, play_anim:bool = true):
	if not note.can_be_missed:
		return
	
	for i in script_stack.size():
		script_stack[i].note_miss(note)
	
	ghost_miss(note.direction, play_anim)


func ghost_miss(direction:int, play_anim:bool = true):
	for i in script_stack.size():
		script_stack[i].ghost_miss(direction)
	
	misses += 1
	health -= 0.875
	score -= 50
	
	if play_anim and player.miss_animations.size() > 0:
		player.play_anim(player.miss_animations[direction])
		SoundHelper.play_sound("res://assets/sounds/game/" + SONG.song_style + "/miss" + str(randi_range(1, 3)) + ".ogg", randf_range(-20, -10))
	
	decrease_combo(true)
	if not voices.stream == null:
		voices.volume_db = -50
	
	display_judgement("miss")
	if combo <= -10 or combo == -1 or combo == 0:
		display_combo(Color8(96, 96, 96))
	
	update_ranking()
	update_score_text()


func decrease_combo(missing:bool, force:bool = false):
	if combo > 0 or force: combo = 0
	if missing: combo -= 1


func display_judgement(judge:String, color = null):
	if not Settings.get_setting("combo_stacking"):
		for j in judgement_group.get_children():
			j.queue_free()
	
	var judgement:FFSprite2D = FFSprite2D.new()
	judgement.texture = load("res://assets/images/ui/ratings/" + SONG.song_style + "/" + judge + ".png")
	if SONG.song_style == "pixel":
		judgement.scale = Vector2(6.0, 6.0)
		judgement.texture_filter = TEXTURE_FILTER_NEAREST
	else:
		judgement.scale = Vector2(0.70, 0.70)
	judgement.position.x += 30
	
	if not color == null:
		judgement.modulate = color
	
	judgement_group.add_child(judgement)
	
	judgement.acceleration.y = 550 * Conductor.pitch_scale
	judgement.velocity.y = -randi_range(140, 175) * Conductor.pitch_scale
	judgement.velocity.x = -randi_range(0, 10) * Conductor.pitch_scale
	
	get_tree().create_tween().tween_property(judgement, "modulate:a", 0.0, 0.50) \
	.set_delay(Conductor.step_crochet * 0.001).finished.connect(func(): judgement.queue_free())


var last_judgement:FFSprite2D:
	get: return judgement_group.get_children()[judgement_group.get_child_count() - 1]


func display_combo(color = null):
	if not Settings.get_setting("combo_stacking"):
		for c in combo_group.get_children():
			c.queue_free()
	
	# split combo in half
	var combo_string:String = ("x" + str(combo)) if not combo < 0 else str(combo)
	var numbers:PackedStringArray = combo_string.split("")
	
	for i in numbers.size():
		var combo_num:FFSprite2D = FFSprite2D.new()
		combo_num.texture = load("res://assets/images/ui/combo/" + SONG.song_style + "/num" + numbers[i] + ".png")
		combo_num.position.x = (45 * i) + last_judgement.position.x - 65
		combo_num.position.y = last_judgement.position.y + 50
		if SONG.song_style == "pixel":
			combo_num.scale = Vector2(6, 6)
			combo_num.texture_filter = TEXTURE_FILTER_NEAREST
		else:
			combo_num.scale = Vector2(0.50, 0.50)
		
		if not color == null:
			combo_num.modulate = color
		
		# offset for new sprites woo
		if numbers[i] == 'x':
			combo_num.position.y += 15
		elif numbers[i] == '-':
			combo_num.position.y += 5
		
		combo_group.add_child(combo_num)
		
		combo_num.acceleration.y = randi_range(200, 350) * Conductor.pitch_scale
		combo_num.velocity.y = -randi_range(140, 160) * Conductor.pitch_scale
		combo_num.velocity.x = -randi_range(-5, 5) * Conductor.pitch_scale
		
		get_tree().create_tween().tween_property(combo_num, "modulate:a", 0.0,  0.2) \
		.set_delay(Conductor.step_crochet * 0.002).finished.connect(combo_num.queue_free)


var rank_name:String = "N/A"
var clear_rank:String = ""
var rankings:Dictionary = {
	"S": 100, "A+": 95, "A": 90, "B": 85, "B-": 80, "C": 70,
	"SX": 69, "D+": 68, "D": 50, "D-": 15, "F": 0
}


func update_ranking():
	# loop through the rankings map
	var biggest:int = 0
	for rank in rankings.keys():
		if rankings[rank] <= accuracy and rankings[rank] >= biggest:
			rank_name = rank
			biggest = accuracy
	
	clear_rank = ""
	if misses == 0: # Etterna shit
		if judgements_gotten["sick"] > 0:
			
			clear_rank = "MFC"
			
		if judgements_gotten["good"] > 0:
			
			if judgements_gotten["good"] >= 10:
				clear_rank = "GFC"
			else:
				clear_rank = "SDG"
			
		if judgements_gotten["bad"] > 0:
			
			if judgements_gotten["bad"] >= 10:
				clear_rank = "FC"
			else:
				clear_rank = "SDB"
	else:
		if misses < 10:
			clear_rank = "SDCB"
