class_name StrumLine extends Control

@onready var game = $"../../"

@onready var receptors:Control = $receptors
var cols:Array[String] = ["purple", "blue", "green", "red"]
var dirs:Array[String] = ["left", "down", "up", "right"]
@export var is_cpu:bool = false
var notes:Control

var notes_copy_alpha:bool = true
var generation_alpha:float = 1

func _init():
	notes = Control.new()
	
func _generate_receptors():
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	for i in dirs:
		receptors.get_node(i).modulate.a = 0
		tween.tween_property(receptors.get_node(i), "modulate:a", generation_alpha,
			(Conductor.step_crochet * 3.5) / 1000)
	add_child(notes)

func _process(_delta:float):
	if notes != null:
		for note in notes.get_children():
			# receptors.get_child()
			if note == null or note.direction > 3:
				note.queue_free()
				notes.remove_child(note)
				return
			
			var receptor := receptors.get_child(note.direction)
			var step_y:float = (Conductor.song_position - note.time) * (0.45 * round(Conductor.scroll_speed));
			note.reset_anim(cols[note.direction])
			
			note.position.x = receptor.position.x
			if Preferences.get_pref("downscroll"):
				note.position.y = receptor.position.y+step_y
			else:
				note.position.y = receptor.position.y-step_y
			
			if notes_copy_alpha:
				note.modulate.a = receptor.modulate.a
			
			# Kill Script
			var note_kill:int = 50 if Preferences.get_pref("downscroll") else -receptor.position.y+100
			if not is_cpu: note_kill = 250+note.sustain_len if Preferences.get_pref("downscroll") else -80-note.sustain_len
			
			var note_killed:bool = note.position.y < note_kill
			if Preferences.get_pref("downscroll"):
				note_killed = note.position.y > note_kill
			
			if note_killed:
				if !is_cpu and !note.was_good_hit:
					game.note_miss(note.direction)
				elif is_cpu:
					var char:Character = game.opponent
					if self == game.player_strums:
						char = game.player
					char.play_anim("sing"+dirs[note.direction].to_upper())
					char.hold_timer = 0.0
					if game.vocals.stream != null:
						game.vocals.volume_db = 0
				remove_note(note)

func add_note(note:Note):
	notes.add_child(note)
	
func remove_note(note:Note):
	note.queue_free()
	notes.remove_child(note)
	
