extends Node

signal step_caller(step:int)
signal beat_caller(beat:int)
signal sect_caller(sect:int)

var bpm:float = 100.0

var position:float = 0.0
var step_position:int = 0
var beat_position:int = 0
var sect_position:int = 0

var crochet:float =  ((60 / bpm) * 1000.0)
var step_crochet:float = crochet / 4.0

var pitch_scale:float = 1.0:
	get: return Settings.get_setting("song_pitch")

var note_offset:float = 0.0:
	get: return Settings.get_setting("note_offset")

func change_bpm(new_bpm:float):
	bpm = new_bpm
	crochet = ((60 / new_bpm) * 1000.0)
	step_crochet = crochet / 4.0

var bpm_changes:Array = []
func map_bpm_changes(chart:Chart):
	bpm_changes = []
	
	var event_steps:int = 0
	var event_time:float = 0.0
	var current_bpm:float = bpm
	
	if chart.events.size() > 1:
		for i in chart.events.size():
			var event:ChartEvent = chart.events[i]
			if event.name == "BPM Change":
				
				event_steps += 16
				current_bpm = event.arguments[0]
				event_time += ((60 / current_bpm) * 1000 / 4) * 16;
				
				var change:Dictionary = {
					"step": int(event_steps),
					"time": float(event_time),
					"bpm": float(current_bpm)
				}
				
				bpm_changes.append(change)
	
	print("bpm change list size ", bpm_changes.size())


var old_step:int = -1
var old_beat:int= -1
var old_sect:int = -1

func _process(_delta:float):
	beat_position = step_position / 4
	sect_position = beat_position / 4
	
	var last_event:Dictionary = {
		"step": 0,
		"time": 0.0,
		"bpm": 0.0
	}
	
	for i in bpm_changes.size():
		if position >= bpm_changes[i]["time"]:
			last_event = bpm_changes[i]
	
	step_position = floor(last_event["step"] + (position - last_event["time"]) / step_crochet)
	
	#Step Hit
	if step_position >= 0:
		if not step_position == old_step: # Step Hit
			step_caller.emit(step_position)
			old_step = step_position
		
		if step_position % 4 == 0 and beat_position > old_beat: # Beat Hit
			beat_caller.emit(beat_position)
			old_beat = beat_position
		
		if beat_position % 4 == 0 and sect_position > old_sect: # Section Hit
			sect_caller.emit(sect_position)
			old_sect = sect_position

func reset():
	old_step = -1
	old_beat = -1
	old_sect = -1
	
	step_position = 0
	beat_position = 0
	sect_position = 0
	
	step_position = 0.0
	beat_position = 0.0
	sect_position = 0.0
