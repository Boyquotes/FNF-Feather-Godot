class_name SongChart extends Resource

var name:String = "Test"
var speed:float = 1.0
var bpm:float = 100.0

var events:Array[ChartEvent] = []
var sections:Array[ChartSection] = []
var characters:Array[String] = ["bf", "dad", "gf"]
var stage:String = "stage"

var ui_style:String = "default"
var type:String = "FNF Legacy/Hybrid"

static func load_chart(song_name:String, difficulty:String = "normal"):
	difficulty = difficulty.to_lower()
	
	var json_path:String = Paths.songs(song_name)+"/"+difficulty+".json"
	if !ResourceLoader.exists(json_path):
		if ResourceLoader.exists(json_path.replace(difficulty, "normal")):
			json_path = Paths.songs(song_name)+"/normal.json"
		else: push_error("Chart for Song "+song_name+" not found on assets/songs/"+song_name+".")
	
	var base_chart = JSON.parse_string(FileAccess.open(json_path, FileAccess.READ).get_as_text()).song
	
	var chart:SongChart = new()
	chart.name = base_chart.song
	chart.speed = base_chart.speed
	chart.bpm = base_chart.bpm
	
	chart.characters[0] = base_chart.player1
	chart.characters[1] = base_chart.player2
	if "gfVersion" in base_chart:
		chart.characters[2] = base_chart.gfVersion
	elif "player3" in base_chart:
		chart.characters[2] = base_chart.player3
	
	if "stage" in base_chart:
		chart.stage = base_chart.stage
	
	if "assetModifier" in base_chart:
		chart.ui_style = base_chart.assetModifier
	elif "uiSkin" in base_chart:
		chart.ui_style = base_chart.uiSkin
	elif "uiStyle" in base_chart:
		chart.ui_style = base_chart.uiStyle
	
	for section in base_chart.notes:
		# Create a new Chart Section
		var my_section:ChartSection = ChartSection.new()
		my_section.bpm = section.bpm if "bpm" in section and section.bpm != null else 0.0
		my_section.change_bpm = section.changeBPM if "changeBPM" in section and section.changeBPM != null else false
		my_section.length_in_steps = section.lengthInSteps if "lengthInSteps" in section and section.lengthInSteps != null else false
		my_section.notes = []
		
		my_section.animation = "-alt" if "altAnim" in section and section.altAnim else ""
		
		if "sectionBeats" in section and section.sectionBeats != null:
			my_section.length_in_steps = int(section.sectionBeats) * 4
		
		var point:int = 1 if section.mustHitSection else 0
		if "gfSection" in my_section:
			chart.type = "PSYCH"
			if section.gfSection: point = 3
		my_section.camera_position = point
		
		for note in section.sectionNotes:
			var my_note:ChartNote = ChartNote.new()
			my_note.step_time = float(note[0])
			my_note.direction = int(note[1]) % 4
			my_note.length = float(note[2])
			
			var _note_press:bool = section.mustHitSection
			if (note[1] > 3): _note_press = !section.mustHitSection
			my_note.strum_line = 1 if _note_press else 0
			
			# notetype conversion
			if (note.size() > 3):
				if note[3] is bool and note[3] == true:
					my_note.suff = "-alt"
				elif note[3] is String:
					match note[3]:
						"Hurt Note": my_note.type = "hurt"
						"Alt Animation": my_note.suff = "-alt"
						_: my_note.type = note[3]
				else: my_note.type = "default"
			else: my_note.type = "default"
			
			# now that the notes are created, push them to our section
			my_section.notes.append(my_note)
		
		# Psych Events
		# for event in base_chart.events:
		
		# and push the section to the chart
		chart.sections.append(my_section)
		chart.events = []
		
		Conductor.change_bpm(chart.bpm)
		Conductor.scroll_speed = chart.speed
	
	return chart

func load_chart_notes():
	var return_notes:Array[ChartNote] = []
	for section in sections:
		for note in section.notes:
			return_notes.append(note)
	return return_notes
