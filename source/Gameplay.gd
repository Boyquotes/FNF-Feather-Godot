extends BeatScene

var song:SongChart

@onready var inst:AudioStreamPlayer = $Music/Inst
@onready var vocals:AudioStreamPlayer = $Music/Vocals

@onready var stage:Stage = $Objects/Stage
@onready var player:Character = $Objects/Player
@onready var opponent:Character = $Objects/Opponent

var dancers:Array[Character]
var singers:Array[Character]

var songName:String = "fresh"
var difficulty:String = "normal"

func _ready():
	song = SongChart.load_chart(songName, difficulty)

	inst.stream = load(Paths.songs(songName+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(songName+"/Voices.ogg"))
	
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
		var increase:int = 0
		if keyEvent.pressed:
			match keyEvent.keycode:
				KEY_ESCAPE: Main.switch_scene("menus/MainMenu")

# Gameplay
var score:int = 0
var misses:int = 0
var health:float = 0
var rating:String = "SFC"

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
