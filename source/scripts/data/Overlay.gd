extends Node2D

func _process(_delta) -> void :
	var text = "FPS: " + String.num(Engine.get_frames_per_second()) + "\n"
	text +=  "RAM: " + String.humanize_size(OS.get_static_memory_usage())
	text += " / " + String.humanize_size(OS.get_static_memory_peak_usage()) + "\n"
	text += "STEP: " + String.num(Conductor.curStep)
	text += " ~ BEAT: " + String.num(Conductor.curBeat)
	text += " ~ SECTION: " + String.num(Conductor.curSect) + "\n"
	$DebugOverlay.text = text
