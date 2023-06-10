extends CanvasLayer

var _show_ram:bool = false

func _ready():
	pass

func _process(_delta:float):
	$Version.text = "FF v" + Versioning.GAME_VERSION + " " + Versioning.grab_schema_name()
	$Text.text = "FPS: " + str(Engine.get_frames_per_second())
	if _show_ram:
		$Text.text += "\n" + Game.humanize_bytes(OS.get_static_memory_usage()) + " / " + \
			Game.humanize_bytes(OS.get_static_memory_peak_usage()) + " [RAM]"

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_F3: _show_ram = not _show_ram
				KEY_F10: visible = not visible
