extends Node2D

var SCREEN:Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0,
		ProjectSettings.get_setting("display/window/size/viewport_height") / 2.0
	)
}


const note_dirs:Array[String] = ["left", "down", "up", "right"]
const note_colors:Array[String] = ["purple", "blue", "green", "red"]

var skip_splash:bool = false


func _ready():
	Settings.load_settings()
	LAST_SCENE = get_tree().current_scene.scene_file_path
	
	if not skip_splash:
		
		var base_tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
		var black_screen:ColorRect = ColorRect.new()
		black_screen.color = Color8(0, 0, 0)
		black_screen.size = Vector2(1280, 720)
		add_child(black_screen)
		
		var white_bird:Sprite2D = Sprite2D.new()
		white_bird.texture = load("res://splash-icon.png")
		white_bird.position = Vector2(640, 320)
		white_bird.modulate.a = 0.0
		add_child(white_bird)
		
		var made_with:Alphabet = Alphabet.new()
		made_with.bold = true
		made_with.text = "Powered by Godot Engine"
		made_with.position = Vector2(100, white_bird.texture.get_height() + 40)
		made_with.modulate.a = 0.0
		add_child(made_with)
		
		base_tween.tween_property(white_bird, "modulate:a", 1.0, 0.50)
		base_tween.tween_property(made_with, "modulate:a", 1.0, 0.80)
		
		await(base_tween.finished)
		
		SoundHelper.play_sound("res://assets/sounds/hey.ogg")
		
		get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE) \
		.tween_property(white_bird, "position:x", 5000, 1.0).set_delay(0.80).finished.connect(white_bird.queue_free)
		
		for i in made_with.get_child_count():
			var letter:AnimatedSprite2D = made_with.get_child(i)
			var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
			tween.tween_property(letter, "modulate:a", 0.0, i * 0.05).set_delay(0.85)
		
		
		await(get_tree().create_timer(2.35).timeout)
		switch_scene("scenes/menus/TitleScreen", true)
	
	else:
		
		switch_scene("scenes/menus/TitleScreen", true)


func _input(event:InputEvent):
	if Input.is_action_just_pressed("volume_up") or Input.is_action_just_pressed("volume_down"):
		var is_up:bool = Input.is_action_just_pressed("volume_up")
		var value:float = 1.0 if is_up else -1.0
		var shift_thing:float = 0.0
		
		if Input.is_key_label_pressed(KEY_SHIFT):
			shift_thing = 1.0 if is_up else -1.0
			value = value + shift_thing
		
		var new_volume:float = clampf(AudioServer.get_bus_volume_db(0) + value, -49, 0)
		AudioServer.set_bus_volume_db(0, new_volume)
		SoundHelper.play_sound("res://assets/sounds/scrollMenu.ogg")
		
		Settings._config.set_value("System", "volume", AudioServer.get_bus_volume_db(0))


### SCENE SWITCHER ###

var LAST_SCENE:String = ""
const TRANSITION = preload("res://game/scenes/backend/Transition.tscn")

var options_to_gameplay:bool = false


func switch_scene(new_scene:String, skip_transition:bool = false, root:String = "game"):
	var scene_folder:String = "res://" + root + "/" + new_scene + ".tscn"
	LAST_SCENE = scene_folder
	
	if not skip_transition:
		var trans = TRANSITION.instantiate()
		add_child(trans)
		
		get_tree().paused = true
		await(get_tree().create_timer(0.45).timeout)
		get_tree().paused = false
	
	get_tree().change_scene_to_file(scene_folder)


func reset_scene(skip_transition:bool = false):
	if not skip_transition:
		var trans = TRANSITION.instantiate()
		add_child(trans)
		
		get_tree().paused = true
		await(get_tree().create_timer(0.45).timeout)
		get_tree().paused = false
	
	get_tree().change_scene_to_file(LAST_SCENE)


### HELPER FUNCTIONS ###

var flicker_loops:int = 8 ## less means faster, REDO THIS LATER PROLLY!!!
var flicker_timer:SceneTreeTimer
var prev_flickered_object = null


func do_object_flick(object = null, duration:float = 0.06, end_vis:bool = false, do_callable = null) -> void:
	
	if flicker_loops <= 0:
		if not object == null:
			if object is Node2D or object is ReferenceRect:
				object.modulate.a = 1.0 if end_vis else 0.0
			elif object is ColorRect:
				object.color.a = 1.0 if end_vis else 0.0
		if not do_callable == null:
			do_callable.call()
			flicker_timer = null
		return
	
	if not object == null:
		if object is Node2D or object is ReferenceRect:
			object.modulate.a = 0.0
		elif object is ColorRect:
			object.color.a = 0.0
	
	if flicker_timer == null or not flicker_loops <= 0:
		flicker_timer = get_tree().create_timer(duration)
		flicker_timer.timeout.connect(
			func():
				await get_tree().create_timer(duration).timeout
			
				flicker_loops -= 1
				do_object_flick(object, duration, end_vis, do_callable)
		)
	
	await flicker_timer.timeout
	
	if not object == null:
		if object is Node2D or object is ReferenceRect:
			object.modulate.a = 1.0
		elif object is ColorRect:
			object.color.a = 1.0



func float_to_minute(value:float): return int(value / 60)
func float_to_seconds(value:float): return fmod(value, 60)
func format_to_time(value:float): return "%02d:%02d" % [float_to_minute(value), float_to_seconds(value)]
func bind_to_fps(rate:float): return rate * (60 / Engine.get_frames_per_second())

### SONG FUNCTIONS ###

@export var game_weeks:Array[GameWeek] = []

### Mode 0 is Story Mode, Mode 2 is Charting Mode, anything else is freeplay
var gameplay_mode:int = 1

var CURRENT_SONG:Chart

var gameplay_song:Dictionary = {
	"name": "Test",
	"folder": "test",
	"playlist": [], # for story mode
	"difficulty": "normal",
	"week_namespace": "???",
	"diffiulties": [],
}

var total_week_score:int = 0


func reset_story_playlist(difficulty:String = "normal"):
	if gameplay_song["playlist"].size() > 0 and gameplay_mode == 0:
		
		gameplay_song["name"] = gameplay_song["playlist"][0].name
		gameplay_song["folder"] = gameplay_song["playlist"][0].folder
		gameplay_song["difficulties"] = gameplay_song["playlist"][0].difficulties
		gameplay_song["difficulty"] = difficulty
		total_week_score = 0


const MENU_MUSIC = "res://assets/music/freakyMenu.ogg"
const PAUSE_MUSIC = "res://assets/music/breakfast.ogg"

var song_saves:ConfigFile = ConfigFile.new()


func save_song_score(song:String, score:int, save_name:String):
	var err:Error = song_saves.load("user://scores.cfg")
	if err == OK: song_saves.set_value(save_name, song, score)
	song_saves.save("user://scores.cfg")


func get_song_score(song:String, save_name:String) -> int:
	var err:Error = song_saves.load("user://scores.cfg")
	if not err == OK:
		save_song_score(song, 0, save_name)
	
	if song_saves.has_section_key(save_name, song):
		return song_saves.get_value(save_name, song)
	return 0
