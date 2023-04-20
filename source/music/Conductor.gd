extends Node

signal on_beat(beat)
signal on_step(step)
signal on_sect(sect)

var bpm:float = 100.0
var crochet:float = ((60 / bpm) * 1000.0) # Beats in Milliseconds
var step_crochet:float = crochet / 4.0 # Steps in Milliseconds
var song_position:float = 0.00

var safe_frames:int = 10
var safe_zone:float = ((safe_frames / 60) * 1000);

var cur_beat:int = 0
var cur_step:int = 0
var cur_sect:int = 0

var bpm_event:BpmChangeEvent = BpmChangeEvent.new()
var bpm_changes:Array[BpmChangeEvent] = []

func change_bpm(new_bpm:float):
	bpm  = new_bpm
	crochet = ((60 / bpm) * 1000)
	step_crochet = crochet / 4

func _process(_delta:float):
	cur_beat = floor(cur_step / 4)
	cur_sect = floor(cur_beat / 4)

	for event in len(bpm_changes) - 1:
		if song_position >= bpm_changes[event].stepTime:
			bpm_event = bpm_changes[event]
	
	cur_step = bpm_event.step_hit+floor((song_position - bpm_event.step_time) / step_crochet)
	process_signals()

# Song Processes
var old_step:int = 0
var old_beat:int = 0
var old_sect:int = 0

func process_signals():
	if cur_step != old_step:
		if cur_step > old_step:
			old_step = cur_step
		on_step.emit(cur_step)
	
	if cur_step % 4 == 0 and cur_beat > old_beat:
		old_beat = cur_beat
		on_beat.emit(cur_beat)
	
	if cur_beat % 4 == 0 and cur_sect > old_sect:
		old_sect = cur_sect
		on_sect.emit(cur_sect)
