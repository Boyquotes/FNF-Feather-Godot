extends BeatScene

enum GameMode {STORY, FREEPLAY, CHARTER}

const Pause_Screen = preload("res://source/gameplay/subScenes/PauseScreen.tscn")

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
@onready var strum_lines:Control = $Strumlines
@onready var player_strums := $Strumlines/playerStrums
@onready var main_camera := $"Shifting Camera"

var noteList:Array[Note] = []

func _ready():
	change_cam(0)
	
	if Song.difficulty_name != null: difficulty = Song.difficulty_name
	if !Song.ignore_song_queue and Song.song_queue.size() > 0:
		var _song:String = Song.song_queue[Song.queue_position]
		if song_name != _song:
			song_name = _song
	
	song = SongChart.load_chart(song_name, difficulty)
	noteList = song.load_notes()
	
	inst.stream = load(Paths.songs(song_name+"/Inst.ogg"))
	vocals.stream = load(Paths.songs(song_name+"/Voices.ogg"))
	
	inst.play()
	vocals.play()
	inst.finished.connect(end_song)
	
	for rating in ratings.keys(): ratings_gotten[rating] = 0

func _process(_delta:float):
	if inst != null and inst.playing:
		Conductor.song_position = inst.get_playback_position() * 1000
	
	if $UI != null:
		update_score_text()
		$UI.update_health_bar(health)
	
	if Input.is_action_just_pressed("pause"):
		var pause = Pause_Screen.instantiate()
		get_tree().current_scene.add_child(pause)
		get_tree().paused = true
	# Load Notes
	spawn_notes()
	
	for strum_line in strum_lines.get_children():
		for note in strum_line.notes.get_children():
			
			# Kill Script
			var note_kill:int = 40
			if !strum_line.is_cpu:
				note_kill = 380+note.sustain_len
			
			if note.position.y > note_kill:
				if !strum_line.is_cpu and !note.was_good_hit: note_miss()
				strum_line.remove_note(note)
			
			var dir:String = strum_line.dirs[note.direction]
			var receptor = player_strums.receptors.get_child(note.direction)
			if Input.is_action_pressed("note_"+dir):
				# Check Note Hits ((((temporary))))
				if note.position.y >= note_kill - 340 and note.strumLine == 1:
					receptor.play(dir.to_lower()+" confirm")
					note_hit(note, player, player_strums)
				# Play Press Animation
				elif receptor != null and receptor.animation.ends_with("confirm"):
					receptor.play(dir.to_lower()+" press")
			# Receptor Reset
			elif !receptor.animation.ends_with("confirm"):
				for i in player_strums.receptors.get_children().size():
					var recep = player_strums.receptors.get_children()[i]
					recep.play("arrow"+strum_line.dirs[i].to_upper())
					
		if (Input.is_action_just_pressed("reset")): note_miss()

func spawn_notes():
	if noteList.size() > 0:
		var unspawned_note:Note = noteList[0]
		if (unspawned_note.time - Conductor.song_position < 3500):
			strum_lines.get_child(unspawned_note.strumLine).add_note(unspawned_note)
			noteList.remove_at(noteList.find(unspawned_note))

func beat_hit(beat:int):
	# 2 is temp
	if beat % 2==0:
		player.dance()
		opponent.dance()
	match song_name.to_lower():
		"bopeebo":
			if beat % 8==7: player.play_anim("hey")

func sect_hit(sect:int):
	change_cam(song.sections[sect].camera_position)

func change_cam(whose:int):
	var char := opponent
	match whose:
		1: char = player
		# 2: char = crowd
		_: char = opponent
	
	# main_camera.get_screen_center_position()
	main_camera.position = Vector2(
		char.get_viewport_rect().position.x,
		char.get_viewport_rect().position.y
	)

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey:
		if keyEvent.pressed: match keyEvent.keycode:
			KEY_2:
				inst.seek(inst.get_playback_position()+5)
				vocals.seek(inst.get_playback_position())
			KEY_6:
				player_strums.is_cpu = !player_strums.is_cpu
				$UI.cpu_text.visible = player_strums.is_cpu
			#KEY_ESCAPE: end_song()

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
var health:float = 50
var rating:String = "N/A"

const scoreSep:String = " ~ "

func update_score_text():
	var actual_acc:float = accuracy * 100 / 100
	
	var tmp_txt:String = "MISSES: "+str(misses)
	tmp_txt+=scoreSep+"SCORE: "+str(score)
	tmp_txt+=scoreSep+"ACCURACY: "+str("%.2f" % actual_acc)+"%"
	if rating.length() > 0:
		tmp_txt+=get_clear_type()
	
	# Use "bbcode_text" instead of "text"
	$UI.score_text.bbcode_text = tmp_txt
	Tools.center_to_obj($UI.score_text, $UI.health_bar, "X")

func note_hit(note:Note, character:Character, strumline:StrumLine):
	if !note.was_good_hit:
		note.was_good_hit = true
		
		character.play_anim("sing" + strumline.dirs[note.direction].to_upper())
		
		# update accuracy
		notes_hit += 1
		update_note_acc(note)
		strumline.remove_note(note)

func note_miss():
	misses+=1
	score+=ratings["miss"][0]
	notes_acc += ratings["miss"][1]
	health += ratings["miss"][3] / 50
	declare_rating()

# Accuracy Handling
var notes_hit:int = 0
var notes_acc:float = 0
var accuracy:float:
	get:
		if notes_acc < 1: return 0.00
		else: return (notes_acc / notes_hit)

# Dictionary Order:
# Score (Integer),Accuracy Gain (Int), Timing (Float), Health Gain (Integer)
var ratings:Dictionary = {
	"sick": [350, 100, 45.0, 100],
	"good": [150, 75, 90.0, 30],
	"bad": [50, 30, 135.0, -20],
	"shit": [-30, -20, 160.0, -20],
	"miss": [-50, -40, null, -50] # Miss has no timings
}

var ratings_gotten:Dictionary = {}

func update_note_acc(note:Note):
	if notes_acc < 0: notes_acc = 0.00001
	var note_diff:float = absf(Conductor.song_position - note.time)
	var rating:String = "sick"
	
	# if note_diff > Conductor.safe_zone * 0.9: rating = "shit"
	# if note_diff > Conductor.safe_zone * 0.7: rating = "bad"
	# if note_diff > Conductor.safe_zone * 0.2: rating = "good"
	
	notes_acc += maxf(0, ratings[rating][1])
	health += ratings[rating][3] / 50
	ratings_gotten[rating] += 1
	declare_rating()

func get_clear_type():
	var rating_colors:Dictionary = {
		"MFC": "CYAN",
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

func declare_rating():
	rating = ""
	if misses == 0:
		if ratings_gotten["sick"] > 0: rating = "MFC"
		if ratings_gotten["good"] > 0: rating = "GFC"
		if ratings_gotten["bad"] or ratings_gotten["shit"] > 0: rating = "FC"
	elif misses < 10: rating = "SDCB"
