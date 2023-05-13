extends CanvasLayer

var vram:float:
	get: return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)

var vtex:float:
	get: return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)

func _ready():
	visible = false

func _process(_delta:float):
	if $MEM.visible:
		var debug_txt:String = ""
		
		debug_txt+="==== SYSTEM ====\n"
		
		debug_txt+="RAM: "+String.humanize_size(OS.get_static_memory_usage())
		debug_txt+=" / "+String.humanize_size(OS.get_static_memory_peak_usage())
		debug_txt+="\nOS: "+OS.get_distribution_name()+" "+OS.get_version()
		# debug_txt+="\nGPU: "+RenderingServer.get_rendering_device()
		debug_txt+="\nVRAM: "+str(String.humanize_size(vram))+ " ~ TRAM: "+str(String.humanize_size(vtex))
		debug_txt+="\nCPU: "+OS.get_processor_name()
		debug_txt+="\nSCENE: "+get_tree().current_scene.name
		
		debug_txt+="\n\n==== MUSIC ====\n"
		
		debug_txt+="CURRENT STEP: "+str(Conductor.cur_step)
		debug_txt+="\nCURRENT BEAT: "+str(Conductor.cur_beat)
		debug_txt+="\nCURRENT SECT: "+str(Conductor.cur_sect)
		debug_txt+="\nCURRENT BPM: "+str(Conductor.bpm)
		$MEM.text = debug_txt
	$FPS.text = "FPS: "+str(Engine.get_frames_per_second())

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_F3: $MEM.visible = !$MEM.visible
			KEY_F4: visible = !visible
