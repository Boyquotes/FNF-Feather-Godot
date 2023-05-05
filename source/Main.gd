extends Node

var SCREEN:Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / 2,
		ProjectSettings.get_setting("display/window/size/viewport_height") / 2
	)
}
const DEF_MAX_FPS:int = 60
var LAST_SCENE:String

func _ready():
	Engine.max_fps = DEF_MAX_FPS
	LAST_SCENE = get_tree().current_scene.scene_file_path
	AudioServer.set_bus_volume_db(0, linear_to_db(Tools.game_volume))
	# Change Current Scene to the Gameplay one
	switch_scene("menus/MainMenu")

var muted:bool = false

func _input(keyEvent:InputEvent):
	var inc:float = 0
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_MINUS: inc-=0.05;
			KEY_EQUAL: inc+=0.05;
			KEY_8: Main.switch_scene("debug/convert/TXT Converter")
			KEY_9: Main.switch_scene("debug/convert/XML Converter")
		
		if inc != 0:
			Tools.game_volume = clampf(Tools.game_volume+inc, 0, 1)
			AudioServer.set_bus_volume_db(0, linear_to_db(Tools.game_volume))
			VolumeBar.show_panel()
			inc = 0

const TRANSITION_SCENE = preload("res://resources/transition/Top-to-Bottom.tscn")

func switch_scene(newScene:String, root:String = "source"):
	get_tree().paused = true
	LAST_SCENE = "res://"+root+"/"+newScene+".tscn"
	get_tree().change_scene_to_file("res://"+root+"/"+newScene+".tscn")
	get_tree().paused = false

func reset_scene(no_transition:bool = false):
	get_tree().paused = true
	get_tree().change_scene_to_file(LAST_SCENE)
	get_tree().paused = false
