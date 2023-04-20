extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER};

var song:SongChart

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var song_name:String = "milf"
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
		if song_name != _song:
			song_name = _song
	
	song = SongChart.load_chart(song_name, difficulty)
	
	inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	inst.volume_db = 0.8
	vocals.volume_db = 0.8
	
	inst.play()
	vocals.play()

func _process(_delta:float):
	if inst != null and inst.playing:
		Conductor.song_position = inst.get_playback_position() * 1000
	
	if $UI != null:
		update_score_text()
		$UI.update_health_bar(health)

func beat_hit(beat:int):
	# 2 is temp
	if beat % 2 == 0:
		player.play_anim("idle")
		opponent.play_anim("idle")

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

func update_score_text():
	var tmp_txt:String = "MISSES: "+str(misses)
	tmp_txt += scoreSep+"SCORE: "+str(score)
	tmp_txt += scoreSep+"ACCURACY: "+str(accuracy)+"%"
	if rating.length() > 0:
		tmp_txt += get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	$UI.score_text.bbcode_text = tmp_txt

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
	var markup_end:String = ""
	if rating_colors.get(rating) != null:
		markup = "[color="+rating_colors.get(rating)+"]"
		markup_end = "[/color]"
	
	# return colored rating if it exists on the rating colors dictio
	var colored_rating:String = " ["+markup+rating+markup_end+"]"
	return colored_rating if markup != "" else " ["+rating+"]" if rating != "" else ""
