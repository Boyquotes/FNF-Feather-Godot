extends Node

var SCREEN:Dictionary = {
	"width": ProjectSettings.get_setting("display/window/size/viewport_width"),
	"height": ProjectSettings.get_setting("display/window/size/viewport_height"),
	"center": Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0,
		ProjectSettings.get_setting("display/window/size/viewport_height") / 2.0
	)
}
var LAST_SCENE:String

var options_to_gameplay:bool = false
var seen_main_menu_intro:bool = false

func _ready():
	Settings.load_config()
	LAST_SCENE = get_tree().current_scene.scene_file_path
	AudioServer.set_bus_volume_db(0, linear_to_db(Tools.game_volume))
	
	init_rpc()
	switch_scene("TitleScreen", "game/scenes/menus", true)

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
			Settings.config.set_value("System Settings", "volume", Tools.game_volume)
			Settings.config.save(Settings._save_file)
			inc = 0

const TOP_TO_BOTTOM_TRANSITION = preload("res://resources/transition/Top-to-Bottom.tscn")
func switch_scene(newScene:String, root:String = "game/scenes", skip_transition:bool = false):
	get_tree().paused = true
	
	if not skip_transition:
		var transition = TOP_TO_BOTTOM_TRANSITION.instantiate()
		add_child(transition)
		
		await(get_tree().create_timer(0.55).timeout)
	
	var scene_folder:String = "res://"+root+"/"+newScene+".tscn"
	var next_tree := get_tree().change_scene_to_file(scene_folder)
	
	LAST_SCENE = scene_folder
	
	get_tree().change_scene_to_file(scene_folder)
	get_tree().paused = false

func reset_scene(skip_transition:bool = false):
	get_tree().paused = true
	
	if not skip_transition:
		var transition = TOP_TO_BOTTOM_TRANSITION.instantiate()
		add_child(transition)
		
		await(get_tree().create_timer(0.35).timeout)
	
	get_tree().change_scene_to_file(LAST_SCENE)
	get_tree().paused = false

func get_transition(trans_res:String, out:bool = false):
	var resource_load:Resource = load("res://resources/transition/"+trans_res+".tscn")
	var trans = resource_load.instantiate()
	return trans

var discord:DiscordRPC

var rpc_buttons:Array[Dictionary] = [
	{label = "Github Source", url = "https://github.com/BeastlyGabi/FNF-Feather-Godot"},
	{label = "Creator's Twitter", url = "https://www.twitter.com/BeastlyGabi"}
]

func init_rpc():
	discord = DiscordRPC.new()
	add_child(discord)
	
	discord.rpc_ready.connect(func(user:Dictionary):
		print("[Discord RPC]: connection started")
		discord.update_presence({
			details = "In the Menus",
			state = "...",
			assets = {large_image = "feather", small_image = "bianca"},
			buttons = rpc_buttons
		})
	)
	discord.rpc_closed.connect(func(): print("[Discord RPC]: connection closed"))
	discord.rpc_error.connect(func(error:int): print("[Discord RPC]: ", error))
	discord.establish_connection(748278415785721997)

func change_rpc(_state:String, _details:String = "In the Menus"):
	if not discord.is_connected_to_client(): return
	
	discord.update_presence({
		details = _details,
		state = _state,
		assets = {large_image = "feather", small_image = "bianca"},
		buttons = rpc_buttons
	})
