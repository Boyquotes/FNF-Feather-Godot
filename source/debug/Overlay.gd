extends Node2D

func _process(_delta : float):
	var text = "FPS: " + String.num(Engine.get_frames_per_second()) + "\n"
	text +=  "RAM: " + String.humanize_size(OS.get_static_memory_usage())
	text += " / " + String.humanize_size(OS.get_static_memory_peak_usage()) + "\n"
	text += "STEP: " + str(Conductor.curStep)
	text += " ~ BEAT: " + str(Conductor.curBeat)
	text += " ~ SECTION: " + str(Conductor.curSect) + "\n"
	#$Counter.text = text
