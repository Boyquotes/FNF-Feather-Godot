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

var songSet : bool = false
var countdownFinished : bool = false

func startSong(newSong : String, difficulty: String = "normal"):
	var nodeStream = get_tree().current_scene.get_node("Music")
	if nodeStream != null:
		musicInst = nodeStream.get_node("Inst")
		musicVocals = nodeStream.get_node("Vocals")
	
	load_song(newSong, difficulty)
	songSet = true
	count = 3

func updateBpm(newBpm : float):
	bpm  = newBpm
	crochet = ((60 / bpm) * 1000)
	stepCrochet = crochet / 4

func _process(delta : float):
	curBeat = floor(curStep / 4)
	curSect = floor(curBeat / 4)

	for event in len(bpmChanges) - 1:
		if songPosition >= bpmChanges[event].stepTime:
			timeEventBpm = bpmChanges[event]
	
	curStep = timeEventBpm.stepHit + floor((songPosition - timeEventBpm.stepTime) / stepCrochet)
	
	if countdownFinished:
		songPosition = musicInst.get_playback_position() * 1000
	elif !countdownFinished and songSet:
		process_countdown(delta)
	process_signals()

# Song Processes
var count : int = 0

func process_countdown(delta : float):
	if count > 0:
		count -= ((bpm / 60) / 2) * chart_speed * delta
	match count:
		0:
			countdownFinished = true
			musicInst.play()
			musicVocals.play()
	print("tick " + str(count))

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
		emit_signal("on_sect")

# Chart Parser

var mySongData : String = ""

var chart_speed : float = 1.0
var chart_bpm : float = 100.0

func load_song(songName : String, songDiff : String = "normal"):
	songDiff = songDiff.to_lower()
	
	var jsonPath : String = Paths.songs(songName) + "/" + songDiff + ".json"
	if !FileAccess.file_exists(jsonPath):
		return
	
	var _fileRef : FileAccess = FileAccess.open(jsonPath, FileAccess.READ)
	var json : String = FileAccess.get_file_as_string(jsonPath)
	var _chart : Dictionary = JSON.parse_string(json)
	pass
	
	updateBpm(chart_bpm)

func process_notes():
	var _notes : Array = []
	var _sections : Array = []
	var _events : Array = []
