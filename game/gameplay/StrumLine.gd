class_name StrumLine extends Control

## REQUIRED FUNCTIONS ##
# in case you wanna inititialize a strumline at any scene
# "func note_miss(direction:int) -> void:"

@onready var game = $"../../"

@onready var receptors:Control = $receptors
@export var is_cpu:bool = false
var notes:Control

var notes_copy_alpha:bool = true
var generation_alpha:float = 1

func _init():
	notes = Control.new()
	
func _generate_receptors(immediately:bool = false):
	if not immediately:
		for i in receptors.get_child_count():
			var receptor = receptors.get_child(i)
			var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			receptor.modulate.a = 0
			tween.tween_property(receptor, "modulate:a", generation_alpha,
				(Conductor.step_crochet * 3.5) / 1000)
	add_child(notes)

func _process(_delta:float):
	if notes != null:
		for note in notes.get_children():
			if note == null or note.direction > 3:
				remove_note(note)
				return
			
			var receptor := receptors.get_child(note.direction)
			var step_y:float = (Conductor.song_position - note.time) * (0.45 * round(Conductor.scroll_speed));
			
			note.position.x = receptor.position.x
			if Settings.get_setting("downscroll"):
				note.position.y = receptor.position.y+step_y
			else:
				note.position.y = receptor.position.y-step_y
			
			if notes_copy_alpha:
				note.modulate.a = receptor.modulate.a
			
			# Kill Script
			var note_kill:int = 50 if Settings.get_setting("downscroll") else -receptor.position.y+100
			if not is_cpu: note_kill = 250+note.sustain_len if Settings.get_setting("downscroll") else -80-note.sustain_len
			
			var note_killed:bool = note.position.y < note_kill
			if Settings.get_setting("downscroll"):
				note_killed = note.position.y > note_kill
			
			if note_killed and not note.debug:
				if !is_cpu and !note.was_good_hit:
					game.note_miss(note.direction)
					note.note_miss(true)
				elif is_cpu:
					var char:Character = game.opponent
					if self == game.player_strums:
						char = game.player
					char.play_anim("sing"+Tools.dirs[note.direction].to_upper(), true)
					char.hold_timer = 0.0
					game.vocals.volume_db = 0
					note.note_hit(false)
				remove_note(note)

func add_note(note:Note):
	notes.add_child(note)

func remove_note(note:Note):
	note.queue_free()
	notes.remove_child(note)
