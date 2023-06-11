extends Note

func _ready():
	super._ready()
	
	var i:int = get_quant_index(time)
	var parts:Array = [arrow, hold, end]
	if has_node("Splash"): parts.append(get_node("Splash"))
	
	for node in parts:
		node.material = material.duplicate()
		node.material.set_shader_parameter("color", quant_colors[i])

var quants:Array[int] = [4, 8, 12, 16, 20, 24, 32, 48, 64] # different quants

var quant_colors:Array[Color] = [
	Color.RED, Color.BLUE, Color.PURPLE,
	Color.YELLOW, Color.PINK, Color.ORANGE,
	Color.CYAN, Color.GREEN, Color.GRAY
]

func get_quant_index(note_time:float) -> int:
	#######################################################################
	# Code from Forever Engine by Yoshubs, gedehari, Pixloen and Scarlett #
	#######################################################################
	
	var beat_millisec = (60 / Conductor.bpm) * 1000.0 # beat in milliseconds
	var measure_time = beat_millisec * 4 # assumed 4 beats per measure?
	var smallest_deviation = measure_time / quants[quants.size() - 1]
	
	for new_quant in quants.size():
		var quant_time:float = measure_time / quants[new_quant]
		if fmod(note_time + smallest_deviation, quant_time) < smallest_deviation * 2:
			return new_quant
	
	return quants[quants.size() - 1]
