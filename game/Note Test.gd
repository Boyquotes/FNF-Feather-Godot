extends Node2D

@onready var strum:StrumLine = $Strumline

func _ready():
	strum.generation_alpha = 0.6
	strum._generate_receptors(false)
	strum.notes_copy_alpha = false
	
	var test_note:Note = Note.new(0, 2, "default")
	test_note.debug = true
	test_note.speed = 2.8
	strum.add_note(test_note)

func _input(k):
	var note:Note = strum.notes.get_child(0)
	if k is InputEventKey:
		if k.pressed:
			match k.keycode:
				KEY_D: note.sustain_len -= 0.1
				KEY_K: note.sustain_len += 0.1
				KEY_F: note.time -= 2
				KEY_J: note.time += 2
				KEY_R: Main.reset_scene()
			#print(note.sustain_len)
			note.kill_sustain()
			note.load_sustain()
