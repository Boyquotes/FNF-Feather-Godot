extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER};

var song:SongChart

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var songName:String = "milf"
var difficulty:String = "hard"

@onready var inst:AudioStreamPlayer = $Music/Inst
@onready var vocals:AudioStreamPlayer = $Music/Vocals

@onready var stage:Stage = $Objects/Stage
@onready var player:Character = $Objects/Player
@onready var opponent:Character = $Objects/Opponent

var dancers:Array[Character]
var singers:Array[Character]

func _ready():
	# print(Globals.song_queue)
	if !Globals.ignore_song_queue and Globals.song_queue.size() > 0:
		var _song:String = Globals.song_queue[Globals.queue_position]
		if songName != _song:
			songName = _song
	
	song = SongChart.load_chart(songName, difficulty)
	
	inst.stream = load(Paths.songs(songName+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(songName+"/Voices.ogg"))
	inst.volume_db = 0.8
	vocals.volume_db = 0.8
	
	inst.play()
	vocals.play()

func _process(_delta:float):
	if inst != null and inst.playing:
		Conductor.songPosition = inst.get_playback_position() * 1000
	
	if $UI != null:
		update_scoreText()
		$UI.update_healthBar(health)

func beatHit(beat:int):
	# 2 is temp
	if beat % 2 == 0:
		player.playAnim("idle")
		opponent.playAnim("idle")

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey:
		if keyEvent.pressed: match keyEvent.keycode:
			KEY_ESCAPE: end_song()

func end_song():
	if Globals.ignore_song_queue or Globals.song_queue.size() <= 0:
		match play_mode:
			_: Main.switch_scene("menus/MainMenu")
		return
	
	Globals.song_queue.pop_front()
	if Globals.song_queue.size() > 0:
		Main.switch_scene("Gameplay")

# Gameplay
var score:int = 0
var misses:int = 0
var health:float = 0
var rating:String = "N/A"

const scoreSep:String = " ~ "

func update_scoreText():
	var tempText:String = "MISSES: "+str(misses)
	tempText += scoreSep+"SCORE: "+str(score)
	tempText += scoreSep+"ACCURACY: "+str(accuracy)+"%"
	if rating.length() > 0:
		tempText += get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	$UI.scoreText.bbcode_text = tempText

# Accuracy Handling
var noteHits:int = 0
var noteAccuracy:int = 0
var accuracy:float = 0.0
# var accuracy:float:
#	get: return noteAccuracy / noteHits
#	set(value): accuracy = value

func get_clear_type():
	var rating_colors:Dictionary = {
		"SFC": "CYAN",
		"GFC": "LIME",
		"FC": "LIGHT_SLATE_GRAY",
		"SDCB": "CRIMSON"
	}
	
	# overenginered bullshit
	var markup:String = ""
	var markupEnd:String = ""
	if rating_colors.get(rating) != null:
		markup = "[color="+rating_colors.get(rating)+"]"
		markupEnd = "[/color]"
	
	# return colored rating if it exists on the rating colors dictio
	var formattedRating:String = " ["+markup+rating+markupEnd+"]"
	return formattedRating if markup != "" else " ["+rating+"]" if rating != "" else ""
