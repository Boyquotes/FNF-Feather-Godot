extends CanvasLayer

func _process(_delta:float):
	$FPS.text = "FPS: ["+str(Engine.get_frames_per_second()) + "]"
	$FPS.text += "\nRAM USAGE: ["+String.humanize_size(OS.get_static_memory_usage()).to_lower() + "]"
	$FPS.text += "\nRAM PEAK: ["+String.humanize_size(OS.get_static_memory_peak_usage()).to_lower() + "]"

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_F4: visible = !visible
