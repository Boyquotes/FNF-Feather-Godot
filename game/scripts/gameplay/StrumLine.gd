class_name StrumLine extends Control

## REQUIRED FUNCTIONS ##
# in case you wanna inititialize a strumline at any scene
# "func note_miss(direction:int) -> void:"
# "func note_hit(note:Note) -> void:"
# "func cpu_note_hit(note:Note) -> void:"

@onready var game = $"../../"

@onready var receptors:Control = $receptors
@onready var splashes:AnimatedSprite2D = $splashes
@export var note_skin:NoteSkin = NoteSkin.new()
@export var is_cpu:bool = false

var notes:Control
var notes_copy_alpha:bool = true
var generation_alpha:float = 1

func _init():
	notes = Control.new()

func _ready():
	for i in receptors.get_child_count():
		var receptor:AnimatedSprite2D = receptors.get_child(i)
		receptor.sprite_frames = load(note_skin.get_strumline_skin())
		receptor.scale = Vector2(note_skin.strum_scale, note_skin.strum_scale)
		
		var receptor_filter = TEXTURE_FILTER_NEAREST \
		if not note_skin.strum_antialiasing else TEXTURE_FILTER_LINEAR
		receptor.texture_filter = receptor_filter

func _generate_receptors(immediately:bool = false):
	if not immediately:
		for i in receptors.get_child_count():
			var receptor:AnimatedSprite2D = receptors.get_child(i)
			var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			receptor.modulate.a = 0
			tween.tween_property(receptor, "modulate:a", generation_alpha,
				(Conductor.step_crochet * 3.5) / 1000)
	add_child(notes)

func _process(delta:float):
	for i in receptors.get_child_count():
		var receptor:AnimatedSprite2D = receptors.get_child(i)
		
		# Receptor Reset
		var total_frames = receptor.sprite_frames.get_frame_count(receptor.animation.get_basename()) - 1
		if is_cpu and receptor.animation.ends_with("confirm") and receptor.frame >= total_frames:
			receptor_play("arrow"+Tools.dirs[i].to_upper(), i)
		
	for note in notes.get_children() :
		var downscroll_multiplier = -1 if Settings.get_setting("downscroll") else 1
		
		var receptor:AnimatedSprite2D = receptors.get_child(note.direction)
		var step_y:float = (Conductor.song_position - note.time) * ((0.45 * \
			downscroll_multiplier) * round(note.speed))
		
		note.global_position.x = receptor.global_position.x
		note.position.y = receptor.position.y - step_y
		
		if notes_copy_alpha:
			note.modulate.a = receptor.modulate.a
		
		# Kill Script
		var note_kill:int = 50 if downscroll_multiplier < 0 else -receptor.position.y+100
		if not is_cpu: note_kill = 250+note.sustain_len if downscroll_multiplier < 0 else -80-note.sustain_len
		
		var note_killed:bool = note.position.y < note_kill
		if Settings.get_setting("downscroll"):
			note_killed = note.position.y > note_kill
		
		if note_killed and not note.debug:	
			# Miss Script
			if not is_cpu and note.must_press and not note.was_good_hit:
				game.note_miss(note.direction, note)
				note.queue_free()
			
			# CPU Hit Script
			if is_cpu and not note.ignore_note:
				var char:Character = game.player if note.must_press else game.opponent
				char.play_anim(game.get_note_anim(note), true)
				char.hold_timer = 0.0
				
				if Settings.get_setting("cpu_receptors_glow"):
					receptor.frame = 0
					receptor_play(Tools.dirs[note.direction]+" confirm", note.direction)
				
				if game.vocals.stream != null: game.vocals.volume_db = 0
				
				note.was_good_hit = true
				note.note_hit(false)
				
				if not note.is_sustain:
					note.queue_free()
		
		# Swordcube's Hold Note input script, thanks I wouldn't be able to
		# Figure it out, @BeastlyGabi
		if note.was_good_hit:
			note.position.y = 50 if downscroll_multiplier < 0 else position.y
			note.arrow.visible = false
			
			if note.must_press or (Settings.get_setting("cpu_receptors_glow") and is_cpu):
				receptor_play(Tools.dirs[note.direction]+" confirm", note.direction)
			
			var char:Character = game.player if note.must_press else game.opponent
			char.play_anim(game.get_note_anim(note), true)
			
			note.sustain_len -= (delta * 1000) * Conductor.song_scale
			if note.sustain_len <= -(Conductor.step_crochet / 1000):
				note.queue_free()
			
			if note.must_press and note.sustain_len >= 80 and \
				not Input.is_action_pressed("note_"+Tools.dirs[note.direction]) and not is_cpu:
					note.was_good_hit = false
					game.note_miss(note.direction)
					note.queue_free()

func pop_splash(number:int):
	if not Settings.get_setting("note_splashes"): return
		
	var random:String = str(randi_range(1, 2))
	var receptor:AnimatedSprite2D = receptors.get_child(number)
	var splash:AnimatedSprite2D = splashes.duplicate()
	
	splash.visible = true
	splash.modulate.a = 0.75
	
	splash.position = Vector2(receptor.position.x, receptor.position.y)
	
	splash.play("note impact " + random + " " + Tools.cols[number])
	#splash.play("splash " + Tools.cols[number] + " " + random)
	splash.animation_finished.connect(splash.queue_free)
	
	add_child(splash)

# event handlers
func _input(event:InputEvent):
	if event is InputEventKey:
		if is_cpu: return
		
		for i in receptors.get_child_count():
			var pressed:bool = Input.is_action_pressed("note_"+Tools.dirs[i])
			var just_pressed:bool = Input.is_action_just_pressed("note_"+Tools.dirs[i])
			var released:bool = Input.is_action_just_released("note_"+Tools.dirs[i])
			var receptor:AnimatedSprite2D = receptors.get_child(i)
			
			if just_pressed:
				if !receptor.animation.ends_with("confirm"):
					receptor_play(Tools.dirs[i]+" press", i)
			
			if released:
				receptor_play("arrow"+Tools.dirs[i].to_upper(), i)

func receptor_play(anim:String, dir:int):
	var receptor:AnimatedSprite2D = receptors.get_child(dir)
	if receptor.frame > receptor.sprite_frames.get_frame_count(anim) - 1:
		receptor.frame = 0
	receptor.play(anim)
