extends Resource

class_name SongChart

var name : String = "Test"
var speed : float = 1.0
var bpm : float = 100.0

var events : Array[ChartEvent] = []
var sections : Array[ChartSection] = []
var characters : Array[String] = ["bf", "dad", "gf"]

var ui_style : String = "default"

static func loadChart(songName : String, difficulty : String = "normal"):
	difficulty = difficulty.to_lower()
	
	var jsonPath : String = Paths.songs(songName) + "/" + difficulty + ".json"
	if !FileAccess.file_exists(jsonPath):
		push_error("Chart for Song " + songName + " not found on assets/data/songs/ " + songName + ".")
	
	var fnfChart = JSON.parse_string(FileAccess.open(jsonPath, FileAccess.READ).get_as_text()).song
	
	var chart : SongChart = new()
	chart.name = fnfChart.song
	chart.speed = fnfChart.speed
	chart.bpm = fnfChart.bpm
	
	chart.characters[0] = fnfChart.player1
	chart.characters[1] = fnfChart.player2
	if "gfVersion" in fnfChart:
		chart.characters[2] = fnfChart.gfVersion
	elif "player3" in fnfChart:
		chart.characters[2] = fnfChart.player3
	print(chart.characters)
	
	if "assetModifier" in fnfChart:
		chart.ui_style = fnfChart.assetModifier
	elif "uiSkin" in fnfChart:
		chart.ui_style = fnfChart.uiSkin
	elif "uiStyle" in fnfChart:
		chart.ui_style = fnfChart.uiStyle
	
	for section in fnfChart.notes:
		# Create a new Chart Section
		var mySection : ChartSection = ChartSection.new()
		if "changeBPM" in section:
			mySection.change_bpm = section.changeBPM
			if "bpm" in section:
				mySection.bpm = section.bpm
		
		mySection.notes = []
		mySection.length_in_steps = section.lengthInSteps
		
		var point : int = 1 if section.mustHitSection else 0
		mySection.camera_position = point
		
		for note in section.sectionNotes:
			var myNote : ChartNote = ChartNote.new()
			myNote.stepTime = float(note[0])
			myNote.direction = int(note[1])
			myNote.sustainLength = float(note[2])
			
			if (int(note[1]) > 3):
				section.mustHitSection = !section.mustHitSection
			
			# notetype conversion
			if (note.size() > 3):
				match note[3]:
					true: myNote.type = "Alt"
					_:
						if note[3] is String: myNote.type = note[3]
						else: myNote.type = "default"
			else:
				myNote.type = "default"
			
			# now that the notes are created, push them to our section
			mySection.notes.append(myNote)
		
		# Psych Events
		# for event in fnfChart.events:
		
		# and push the section to the chart
		chart.sections.append(mySection)
		chart.events = []
		
		Conductor.changeBpm(chart.bpm)
	return chart
