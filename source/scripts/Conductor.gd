extends Node

var bpm : float = 100.0
var crochet : float = ((60 / bpm) * 1000) # Beats in Milliseconds
var stepCrochet : float = crochet / 4 # Steps in Milliseconds
var songPosition : float = 0.00

var curBeat : int = 0
var curStep : int = 0
var curSec : int = 0

var newTime : Event_BpmChange = Event_BpmChange.new()
var bpmChanges : Array[Event_BpmChange] = []

var oldStep : int = 0
var oldBeat : int = 0
var oldSec : int = 0

func _process(_delta) -> void :
	curBeat = floor(curStep / 4)
	curSec = floor(curBeat / 4)

	for event in len(bpmChanges) - 1:
		if songPosition >= bpmChanges[event].stepTime:
			newTime = bpmChanges[event]
	
	curStep = newTime.stepHit + floor((songPosition - newTime.stepTime) / stepCrochet)
	
	if curStep != oldStep:
		if curStep > oldStep:
			oldStep = curStep
		onStep(curStep)
	
	if curStep % 4 == 0 and curBeat > oldBeat:
		oldBeat = curBeat
		onBeat(curBeat)
	
	if curBeat % 4 == 0 and curSec > oldSec:
		oldSec = curSec
		onSec(curSec)

func onStep(_step : int) -> void : pass
func onBeat(_beat : int) -> void : pass
func onSec(_sec : int) -> void : pass
