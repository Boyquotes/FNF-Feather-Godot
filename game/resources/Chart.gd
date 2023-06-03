class_name Chart extends Resource

var name:String = "Test"
#PLAYER 1, PLAYER 2, SPECTATOR
var characters:Array[String] = ["bf", "dad", "gf"]
var stage:String = "stage"

var bpm:float = 100.0
var speed:float = 1.0

var notes:Array[ChartNote] = []
var events:Array[ChartEvent] = []

var song_style:String = "normal"


static func load_chart(song_name:String, difficulty:String = "normal") -> Chart:
	var base:String = "res://assets/songs/" + song_name.to_lower()
	
	var folder:String = base + "/" + difficulty.to_lower() + ".json"
	if not ResourceLoader.exists(folder):
		folder = base + "/normal.json" # Default Difficulty
	
	var chart_json = JSON.parse_string(FileAccess.open(folder, FileAccess.READ).get_as_text()).song
	var my_chart:Chart = Chart.new()
	
	my_chart.name = song_name.to_lower()
	my_chart.speed = chart_json.speed
	my_chart.bpm = chart_json.bpm
	
	if "player1" in chart_json and not chart_json.player1 == null: my_chart.characters[0] = chart_json.player1
	if "player2" in chart_json and not chart_json.player2 == null: my_chart.characters[1] = chart_json.player2
	if "player3" in chart_json and not chart_json.player3 == null: my_chart.characters[2] = chart_json.player3
	if "gfVersion" in chart_json and not chart_json.gfVersion == null: my_chart.characters[2] = chart_json.gfVersion
	if "stage" in chart_json and not chart_json.stage == null: my_chart.stage = chart_json.stage
	
	
	if "noteStyle" in chart_json and not chart_json.noteStyle == null: my_chart.song_style = chart_json.noteStyle
	if "assetModifier" in chart_json and not chart_json.assetModifier == null: my_chart.song_style = chart_json.assetModifier
	if "assetStyle" in chart_json and not chart_json.assetStyle == null: my_chart.song_style = chart_json.assetStyle
	if "songStyle" in chart_json and not chart_json.songStyle == null: my_chart.song_style = chart_json.songStyle
	
	
	for section in chart_json.notes:
		
		if "mustHitSection" in section:
			var pan_event:ChartEvent = ChartEvent.new()
			pan_event.name = "Camera Pan"
			pan_event.arguments.append("player" if section.mustHitSection \
				else "cpu")
			
			my_chart.events.append(pan_event)
		
		if "changeBPM" in section and "bpm" in section and section.changeBPM:
				var bpm_event:ChartEvent = ChartEvent.new()
				bpm_event.name = "BPM Change"
				bpm_event.arguments.append(section.bpm)
				my_chart.events.append(bpm_event)
		
		for note in section.sectionNotes:
			
			var epic_note:ChartNote = ChartNote.new()
			epic_note.time = float(note[0])
			epic_note.direction = int(note[1]) % 4
			epic_note.length = float(note[2])
			
			var _note_hit:int = 1 if section.mustHitSection else 0
			if (note[1] > 3):
				_note_hit = 1 if !section.mustHitSection else 0
			
			epic_note.strum_line = _note_hit
			
			if note.size() > 3:
				
				if note[3] is bool and note[3] == true:
					epic_note.animation = "-alt"
				elif note[3] is String:
					match note[3]:
						"Hurt Note": epic_note.type = "mine"
						"Alt Animation": epic_note.animation = "-alt"
						_: epic_note.type = note[3] if not note[3] == null else "default"
				else:
					epic_note.type = "default"
			
			my_chart.notes.append(epic_note)
	
	Conductor.change_bpm(my_chart.bpm)
	Conductor.map_bpm_changes(my_chart)
	
	return my_chart
