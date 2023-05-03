class_name StrumLine extends Control

var cpu:bool = false

@onready var receptors:Control = $receptors
var cols:Array[String] = ["purple", "blue", "green", "red"]
var dirs:Array[String] = ["left", "down", "up", "right"]
var notes:Control

func _init():
	notes = Control.new()
	
func _ready():
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	for i in dirs:
		receptors.get_node(i).modulate.a = 0
		tween.tween_property(receptors.get_node(i), "modulate:a", 1,
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
			
			var step_y:float = (Conductor.song_position - note.time) * (0.45 * round(Conductor.scroll_speed));
			
			if note.arrow != null: note.arrow.play(cols[note.direction])
			note.position.x = receptors.get_child(note.direction).position.x
			note.position.y = receptors.get_child(note.direction).position.y + step_y

func add_note(note:Note):
	notes.add_child(note)
