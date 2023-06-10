extends CanvasLayer

func _process(_delta:float):
	
	$Text.text = "FPS: " + str(Engine.get_frames_per_second())
	$Text.text += "\n" + Game.humanize_bytes(OS.get_static_memory_usage()) + " / " + \
		Game.humanize_bytes(OS.get_static_memory_peak_usage()) + " [RAM]"
	
	$Text.text += "\nFeather v" + Versioning.GAME_VERSION + " " + Versioning.grab_schema_name()
	
	$ColorRect.size.x = $Text.size.x + 5
