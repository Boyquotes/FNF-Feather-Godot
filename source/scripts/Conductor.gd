extends Node

signal on_beat(beat)
signal on_step(step)
signal on_sect(sect)

var bpm : float = 100.0
var crochet : float = ((60 / bpm) * 1000) # Beats in Milliseconds
var stepCrochet : float = crochet / 4 # Steps in Milliseconds
var songPosition : float = 0.00

var curBeat : int = 0
var curStep : int = 0
var curSect : int = 0

var timeEventBpm : BpmChangeEvent = BpmChangeEvent.new()
var bpmChanges : Array[BpmChangeEvent] = []

var musicInst : AudioStreamPlayer
var musicVocals : AudioStreamPlayer

func startSong(newSong : String, songBpm : float = 100) -> void :
	var nodeStream = get_tree().current_scene.get_node("Music")
	if nodeStream != null:
		musicInst = nodeStream.get_node("Inst")
		musicVocals = nodeStream.get_node("Vocals")
	updateBpm(songBpm)
	
	musicInst.play()
	musicVocals.play()

func updateBpm(newBpm : float) -> void :
	bpm  = newBpm
	crochet = ((60 / bpm) * 1000)
	stepCrochet = crochet / 4

func _process(delta : float) -> void :
	curBeat = floor(curStep / 4)
	curSect = floor(curBeat / 4)

	for event in len(bpmChanges) - 1:
		if songPosition >= bpmChanges[event].stepTime:
			timeEventBpm = bpmChanges[event]
	
	curStep = timeEventBpm.stepHit + floor((songPosition - timeEventBpm.stepTime) / stepCrochet)
	
	songPosition = musicInst.get_playback_position() * 1000
	process_signals()
	

var oldStep : int = 0
var oldBeat : int = 0
var oldSect : int = 0

func process_signals():
	if curStep != oldStep:
		if curStep > oldStep:
			oldStep = curStep
		emit_signal("on_step")
	
	if curStep % 4 == 0 and curBeat > oldBeat:
		oldBeat = curBeat
		emit_signal("on_beat")
	
	if curBeat % 4 == 0 and curSect > oldSect:
		oldSect = curSect
		emit_signal("on_sec")

func process_vocalResync():
	pass
