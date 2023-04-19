extends Node

signal on_beat(beat)
signal on_step(step)
signal on_sect(sect)

var bpm:float = 100.0
var crochet:float = ((60 / bpm) * 1000.0) # Beats in Milliseconds
var stepCrochet:float = crochet / 4.0 # Steps in Milliseconds
var songPosition:float = 0.00

var safeZone:float = ((10 / 60) * 1000);

var curBeat:int = 0
var curStep:int = 0
var curSect:int = 0

var timeEventBpm:BpmChangeEvent = BpmChangeEvent.new()
var bpmChanges:Array[BpmChangeEvent] = []

func changeBpm(newBpm:float):
	bpm  = newBpm
	crochet = ((60 / bpm) * 1000)
	stepCrochet = crochet / 4

func _process(_delta:float):
	curBeat = floor(curStep / 4)
	curSect = floor(curBeat / 4)

	for event in len(bpmChanges) - 1:
		if songPosition >= bpmChanges[event].stepTime:
			timeEventBpm = bpmChanges[event]
	
	curStep = timeEventBpm.stepHit+floor((songPosition - timeEventBpm.stepTime) / stepCrochet)
	process_signals()

# Song Processes
var oldStep:int = 0
var oldBeat:int = 0
var oldSect:int = 0

func process_signals():
	if curStep != oldStep:
		if curStep > oldStep:
			oldStep = curStep
		on_step.emit(curStep)
	
	if curStep % 4 == 0 and curBeat > oldBeat:
		oldBeat = curBeat
		on_beat.emit(curBeat)
	
	if curBeat % 4 == 0 and curSect > oldSect:
		oldSect = curSect
		on_sect.emit(curSect)
