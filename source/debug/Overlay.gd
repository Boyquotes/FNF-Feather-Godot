extends CanvasLayer

var debug_enabled:bool = false

func _process(_delta:float):
	var overlay_txt:String = "FPS: "+str(Engine.get_frames_per_second())
	if debug_enabled:
		overlay_txt+=" | RAM: "+String.humanize_size(OS.get_static_memory_usage())
		overlay_txt+=" / "+String.humanize_size(OS.get_static_memory_peak_usage())
		overlay_txt+="\nSTEP: "+str(Conductor.cur_step)
		overlay_txt+=" ~ BEAT: "+str(Conductor.cur_beat)
		overlay_txt+=" ~ SECT: "+str(Conductor.cur_sect)
	$Label.text = overlay_txt

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_F3: debug_enabled = !debug_enabled
			KEY_F4: $Label.visible = !$Label.visible
