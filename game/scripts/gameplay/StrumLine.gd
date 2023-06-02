class_name StrumLine extends Node2D

@export var is_cpu:bool = true
@onready var receptors:Control = $Receptors
@onready var notes:CanvasGroup = $Notes
@onready var game = $"../../../"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta:float):
	for note in notes.get_children():
		var downscroll_multiplier = 1 if Settings.get_setting("downscroll") else -1
		
		var distance = (Conductor.position - note.time) * (0.45 * round(note.speed))
		
		var receptor = receptors.get_child(note.direction)
		note.position = Vector2(receptor.position.x, receptor.position.y + distance * downscroll_multiplier)
		receptor.cpu_receptor = is_cpu
		
		var kill_position:float = -25
		if not is_cpu: kill_position = -200
		
		if -distance <= kill_position:
			if not is_cpu and not note.was_good_hit:
				game.note_miss(note)
				note.queue_free()
			
			# CPU Hit Script
			if is_cpu: game.cpu_note_hit(note, self)
			
		# Swordcube's Hold Note input script, thanks I wouldn't be able to
		# Figure it out, @BeastlyGabi
		if note.was_good_hit:
			if note.is_hold:
				note.position.y = 25 if downscroll_multiplier else receptor.position.y
				note.arrow.visible = false
				note.z_index = -1
				
				receptor.play_anim(Game.note_dirs[note.direction].to_lower() + " confirm", true)
				
				var char:Character = game.player if note.must_press else game.cpu
				char.play_anim("sing" + Game.note_dirs[note.direction].to_upper(), true)
				
				note.hold_length -= (delta * 1000) / Conductor.pitch_scale
				if note.hold_length <= -(Conductor.step_crochet / 1000):
					note.queue_free()
				
				#if not is_cpu and note.must_press and note.hold_length >= 80 and \
				#	not Input.is_action_pressed("note_"+GameRoot.note_dirs[note.direction].to_lower()):
				#		note.was_good_hit = false
				#		note.can_be_hit = false
				#		game.note_miss(note.direction)
				#		note.queue_free()

func pop_splash(direction:int):
	var splash:AnimatedSprite2D = $Splash_Template.duplicate()
	
	splash.visible = true
	splash.modulate.a = 0.70
	
	splash.position = receptors.get_child(direction).position
	splash.play("note impact " + str(randi_range(1, 2)) + " " + Game.note_colors[direction], randf_range(0.5, 1.0))
	splash.animation_finished.connect(splash.queue_free)
	
	add_child(splash)

func _input(event:InputEvent):
	if event is InputEventKey:
		if is_cpu: return
		
		for i in receptors.get_child_count():
			var pressed:bool = Input.is_action_pressed("note_" + Game.note_dirs[i])
			var just_pressed:bool = Input.is_action_just_pressed("note_" + Game.note_dirs[i])
			var released:bool = Input.is_action_just_released("note_" + Game.note_dirs[i])
			var receptor:Receptor = receptors.get_child(i)
			
			if just_pressed:
				if !receptor.animation.ends_with("confirm"):
					receptor.play_anim(Game.note_dirs[i] + " press", true)
			
			if released:
				receptor.play_anim("arrow" + Game.note_dirs[i].to_upper(), true)
