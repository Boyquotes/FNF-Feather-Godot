extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER};
enum HitType {POSITIVE, NEGATIVE}

var song:SongChart

# Default is Freeplay
var play_mode:GameMode = GameMode.FREEPLAY

var song_name:String = "dadbattle"
var difficulty:String = "normal"

@onready var inst:AudioStreamPlayer = $Music/Inst
@onready var vocals:AudioStreamPlayer = $Music/Vocals

@onready var stage:Stage = $Objects/Stage
@onready var player:Character = $Objects/Player
@onready var opponent:Character = $Objects/Opponent
@onready var strumLines:Control = $Strumlines
@onready var playerStrums := $Strumlines/playerStrums

var dancers:Array[Character] = []
var singers:Array[Character] = []
var noteList:Array[Note] = []

func _ready():
	# print(Globals.song_queue)
	if Song.difficulty_name != null: difficulty = Song.difficulty_name
	if !Song.ignore_song_queue and Song.song_queue.size() > 0:
		var _song:String = Song.song_queue[Song.queue_position]
		if song_name != _song:
			song_name = _song
	
	song = SongChart.load_chart(song_name, difficulty)
	noteList = song.load_notes()
	
	inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	inst.volume_db = 0.8
	vocals.volume_db = 0.8
	
	inst.play()
	vocals.play()
	inst.finished.connect(end_song)

func _process(_delta:float):
	if inst != null and inst.playing:
		Conductor.song_position = inst.get_playback_position() * 1000
	
	if $UI != null:
		update_score_text()
		$UI.update_health_bar(health)
		
	# Load Notes
	spawn_notes()
	
	for strum_line in strumLines.get_children():
		for note in strum_line.notes.get_children():
			
			# Kill Script
			var note_kill:int = 40
			if !strum_line.is_cpu:
				note_kill = 380+note.sustain_len
			
			if note.position.y > note_kill:
				if !strum_line.is_cpu and !note.was_good_hit:
					note_miss()
					score_accuracy_shenanigans(HitType.NEGATIVE)
				strum_line.remove_note(note)
				
			if note.direction > 3:
				note.direction = 0
			
			var dir:String = strum_line.dirs[note.direction]
			var receptor = playerStrums.receptors.get_child(note.direction)
			if Input.is_action_pressed("note_"+dir):
				# Check Note Hits ((((temporary))))
				if note.position.y >= note_kill - 340 and note.strumLine == 1:
					receptor.play(dir.to_lower()+" confirm")
					note_hit(note, playerStrums)
					score_accuracy_shenanigans(HitType.POSITIVE)
				# Play Press Animation
				elif receptor != null and receptor.animation.ends_with("confirm"):
					receptor.play(dir.to_lower()+" press")
			# Receptor Reset
			elif !receptor.animation.ends_with("confirm"):
				for i in playerStrums.receptors.get_children().size():
					var recep = playerStrums.receptors.get_children()[i]
					recep.play("arrow"+strum_line.dirs[i].to_upper())

func spawn_notes():
	if noteList.size() > 0:
		var unspawned_note:Note = noteList[0]
	
		if (unspawned_note.time - Conductor.song_position < 3500):
			# print('note time is '+str(unspawned_note.time))
			strumLines.get_child(unspawned_note.strumLine).add_note(unspawned_note)
			noteList.remove_at(noteList.find(unspawned_note))
	
func beat_hit(beat:int):
	# 2 is temp
	if beat % 2==0:
		player.dance()
		opponent.dance()
	match song_name.to_lower():
		"bopeebo":
			if beat % 8==7: player.play_anim("hey")

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey:
		if keyEvent.pressed: match keyEvent.keycode:
			KEY_2:
				inst.seek(inst.get_playback_position()+5)
				vocals.seek(inst.get_playback_position())
			KEY_ESCAPE: end_song()

func end_song():
	Song.song_queue.pop_front()
	if Song.ignore_song_queue or Song.song_queue.size() <= 0:
		match play_mode:
			_: Main.switch_scene("menus/FreeplayMenu")
		return
	if Song.song_queue.size() > 0:
		Main.switch_scene("Gameplay")

# Gameplay
var score:int = 0
var misses:int = 0
var health:float = 0
var rating:String = "N/A"

const scoreSep:String = " ~ "


func update_score_text():
	var tmp_txt:String = "MISSES: "+str(misses)
	tmp_txt+=scoreSep+"SCORE: "+str(score)
	tmp_txt+=scoreSep+"ACCURACY: "+str(accuracy)+"%"
	if rating.length() > 0:
		tmp_txt+=get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	$UI.score_text.bbcode_text = tmp_txt

func note_hit(note:Note, strumline:StrumLine):
	if !note.was_good_hit:
		note.was_good_hit = true
		strumline.remove_note(note)

func note_miss():
	misses+=1
	score-=100

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

func score_accuracy_shenanigans(hitType:HitType):
	match hitType:
		HitType.POSITIVE:
			score+=350
			accuracy+=0.5
		HitType.NEGATIVE:
			score-=randi_range(50, 100)
			accuracy-=randi_range(0.1, 0.3)
