extends Node

signal step_caller(step:int)
signal beat_caller(beat:int)
signal bar_caller(bar:int)

var bpm:float = 100.0

var position:float = 0.0
var step_position:int = 0
var beat_position:int = 0
var bar_position:int = 0 #In musical notation blahblah this is sectiob

var crochet:float =  ((60 / bpm) * 1000.0)
var step_crochet:float = crochet / 4.0

var pitch_scale:float = 1.0:
	get: return Settings.get_setting("song_pitch")

var threshold:float = (bpm) / pitch_scale


func change_bpm(new_bpm:float):
	bpm = new_bpm
	crochet = ((60 / new_bpm) * 1000.0)
	step_crochet = crochet / 4.0

var old_step:float = -1.0
var old_beat:float = -1.0
var old_bar:float = -1.0


func _process(delta:float):
	beat_position = step_position / 4
	bar_position = beat_position / 4
	
	#I should put BPM events here too :p
	step_position = floor(0 + (position - 0) / step_crochet)
	
	#Step Hit
	if step_position >= 0:
		if not step_position == old_step:
			step_caller.emit(step_position)
			old_step = step_position
		
		if step_position % 4 == 0 and beat_position > old_beat: #Beat Hit
			beat_caller.emit(beat_position)
			old_beat = beat_position
		
		if beat_position % 4 == 0 and bar_position > old_bar: #Section Hit
			bar_caller.emit(bar_position)
			old_bar = bar_position


func reset():
	old_step = -1.0
	old_beat = -1.0
	old_bar = -1.0
	
	step_position = 0.0
	beat_position = 0.0
	bar_position = 0.0
