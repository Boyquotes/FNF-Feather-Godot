extends Node

var _prefs:Dictionary = {
	# Gameplay
	"downscroll": false, # Sets your Strumline's Vertical Position to the bottom
	"center_notes": false, # Sets your Strumline's Position to the Center of the Screen
	"ghost_tapping": true, # Tapping when there's no notes to hit won't punish you

	"note_speed": 0.0, # Define your Custom Scroll Speed | 0 = Chart Speed

	"framerate": 120, # Define the maximum framerate the game can go
	"vsync": false, # Eliminates screen tearing by limiting your GPU's Framerate
	
	# Accessibility
	"stage_darkness": 0, # Darkens non-UI elements
	"reduced_motion": false, # If moving objects should move less/stop moving
	"flashing_lights": true, # Whether flashing lights should be enabled on menus

	# Customization
	"timing_preset": "feather", # Define your judgement timing presets
	"judgement_counter": "left", # If set to a direction, a counter which counts judgements amounts will be shown
	"hud_judgements": false, # Locks the Judgements and Combo on the HUD

	# the following only work if "judgements_on_hud" is enabled
	"judgement_position": [0.0, 0.0],
	"combo_position": [0.0, 0.0],

	# Default, Quant, Etc. . .
	"note_skin": "default", # Define your Note's Appearance
}

func _ready():
	load_config()

func get_setting(_name:String): return _prefs[_name]
func set_setting(_name:String, value:Variant): _prefs[_name] = value

var _save_file:String = "res://settings.cfg"

func save_config():
	var config:ConfigFile = ConfigFile.new()
	# print("saving Settings")
	for setting in _prefs: config.set_value("Game Settings", setting, _prefs[setting])
	config.save(_save_file)

func load_config():
	var config:ConfigFile = ConfigFile.new()
	var loader:Error = config.load(_save_file)
	
	if loader != OK:
		save_config()
		return
	
	# print("loading Settings")
	for setting in _prefs:
		if config.has_section_key("Game Settings", setting):
			var save_value:Variant = config.get_value("Game Settings", setting)
			_prefs[setting] = save_value
			# print(save_value)
	update_prefs()

func update_prefs():
	Engine.max_fps = _prefs["framerate"]
	
	var v_sync_mode = DisplayServer.VSYNC_DISABLED
	if _prefs["vsync"]: v_sync_mode = DisplayServer.VSYNC_ENABLED
	DisplayServer.window_set_vsync_mode(v_sync_mode)
