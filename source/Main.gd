extends Node

var GAME_SIZE:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
const DEF_MAX_FPS:int = 60

func _ready():
	Engine.max_fps = DEF_MAX_FPS
	# Change Current Scene to the Gameplay one
	switch_scene("menus/MainMenu")

var muted:bool = false

func _input(keyEvent:InputEvent):
	var inc:float = 0
	if keyEvent is InputEventKey:
		if keyEvent.pressed:
			match keyEvent.keycode:
				KEY_MINUS: inc -= 0.05;
				KEY_EQUAL: inc += 0.05;
				KEY_8: Main.switch_scene("tools/convert/TXT Converter")
				KEY_9: Main.switch_scene("tools/convert/XML Converter")
			
			if inc != 0:
				Globals.game_volume = clamp(Globals.game_volume + inc, 0, 1)
				AudioServer.set_bus_volume_db(0, linear_to_db(Globals.game_volume))
				VolumeBar.snd.play(0.0)
				inc = 0

func switch_scene(newScene:String, root:String = "source"):
	# print("Switching Scene to "+newScene+" Scene")
	get_tree().change_scene_to_file("res://"+root+"/"+newScene+".tscn")
