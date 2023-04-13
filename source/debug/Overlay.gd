extends Node2D

func _process(delta):
	var newText : String = "FPS: " + str(Engine.get_frames_per_second())
	newText += " | RAM: " + String.humanize_size(OS.get_static_memory_usage())
	newText += " / " + String.humanize_size(OS.get_static_memory_peak_usage())
	newText += "\nSTEP: " + str(Conductor.curStep)
	newText += " ~ BEAT: " + str(Conductor.curBeat)
	newText += " ~ SECT: " + str(Conductor.curSect)
	$Label.text = newText
