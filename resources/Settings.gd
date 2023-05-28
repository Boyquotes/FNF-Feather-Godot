extends Node

var _prefs:Dictionary = {
	# Gameplay
	"downscroll": false, #Sets your Strumline's Vertical Position to the bottom
	"center_notes": false, #Sets your Strumline's Position to the Center of the Screen
	"ghost_tapping": true, #Tapping when there's no notes to hit won't punish you

	"note_speed": 0.0, #Define your Custom Scroll Speed | 0 = Chart Speed

	"framerate": 120, #Define the maximum framerate the game can go
	"vsync": true, #Eliminates screen tearing by limiting your GPU's Framerate
	
	#Accessibility
	"reduced_motion": false, #If moving objects should move less/stop moving
	"flashing_lights": true, #If flashing lights should be enabled on menus

	#Customization
	"combo_stacking": true, #If Judgements and Combo should stack on top of each other
	"misses_over_score": false, #Replaces "Score" with "Misses" on the UI
	"judgement_counter": "left", #If set to a direction, a counter which counts judgements amounts will be shown
	"hud_judgements": false, #Locks the Judgements and Combo on the HUD
	"note_splashes": true, #If note splashes should pop whenever you hit a sick or a note that has them
	
	"beat_colored_notes": false, #If the notes should be colored according to the song beat
	"opaque_sustains": false, #If sustain notes should be completely opaque instead of slightly transparent
	"cpu_receptors_glow": false, #If the receptors on the CPUs should glow lie the player's receptors

	#the following only work if "judgements_on_hud" is enabled
	"judgement_position": [0.0, 0.0],
	"combo_position": [0.0, 0.0],
}

func _ready():
	load_config()

func get_setting(_name:String): return _prefs[_name]
func set_setting(_name:String, value:Variant): _prefs[_name] = value

var config:ConfigFile
var _save_file:String = "user://settings.cfg"

func save_config():
	if config == null: config = ConfigFile.new()
	for setting in _prefs: config.set_value("Game Settings", setting, _prefs[setting])
	config.save(_save_file)

func load_config():
	if config == null: config = ConfigFile.new()
	var loader:Error = config.load(_save_file)
	
	if loader != OK:
		save_config()
		return
	
	for setting in _prefs:
		if config.has_section_key("Game Settings", setting):
			_prefs[setting] = config.get_value("Game Settings", setting)
	update_prefs()

func update_prefs():
	Engine.max_fps = _prefs["framerate"]
	if config.has_section_key("System Settings", "volume"):
		Tools.game_volume = config.get_value("System Settings", "volume")
	
	var v_sync_mode = DisplayServer.VSYNC_DISABLED
	if _prefs["vsync"]: v_sync_mode = DisplayServer.VSYNC_ADAPTIVE
	DisplayServer.window_set_vsync_mode(v_sync_mode)
