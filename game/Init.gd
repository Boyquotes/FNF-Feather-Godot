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
	Settings.load_config()
	LAST_SCENE = get_tree().current_scene.scene_file_path
	AudioServer.set_bus_volume_db(0, linear_to_db(Tools.game_volume))
	
	# Change Current Scene to the Gameplay one
	switch_scene("MainMenu", "game/scenes/menus", true)

var muted:bool = false

func _input(keyEvent:InputEvent):
	var inc:float = 0
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_MINUS: inc-=0.05;
			KEY_EQUAL: inc+=0.05;
			KEY_PAGEDOWN:
				# hot reloading
				Settings.load_config()
				Main.reset_scene()
			KEY_8: Main.switch_scene("converters/TXT Converter", "game")
			KEY_9: Main.switch_scene("converters/XML Converter", "game")
		
		if inc != 0:
			Tools.game_volume = clampf(Tools.game_volume+inc, 0, 1)
			AudioServer.set_bus_volume_db(0, linear_to_db(Tools.game_volume))
			VolumeBar.show_panel()
			inc = 0

func switch_scene(newScene:String, root:String = "game/scenes", skip_transition:bool = false):
	get_tree().paused = true
	
	var scene_folder:String = "res://"+root+"/"+newScene+".tscn"
	var next_tree := get_tree().change_scene_to_file(scene_folder)
	
	LAST_SCENE = scene_folder
	get_tree().change_scene_to_file(scene_folder)
	get_tree().paused = false

func reset_scene(skip_transition:bool = false):
	get_tree().paused = true
	get_tree().change_scene_to_file(LAST_SCENE)
	get_tree().paused = false

func get_transition(trans_res:String, out:bool = false):
	var resource_load:Resource = load("res://resources/transition/"+trans_res+".tscn")
	var trans = resource_load.instantiate()
	return trans
