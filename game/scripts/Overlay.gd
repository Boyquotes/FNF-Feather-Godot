extends CanvasLayer


func _process(_delta:float):
	$Text.text = "FPS: " + str(Engine.get_frames_per_second())
	$Text.text += "\nRAM USAGE: " + String.humanize_size(OS.get_static_memory_usage())
	$Text.text += "\nRAM PEAK: " + String.humanize_size(OS.get_static_memory_peak_usage())
