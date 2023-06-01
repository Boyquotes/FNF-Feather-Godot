extends Node

var _prefs:Dictionary = {
	"downscroll": true,
	"centered_receptors": false,
	"flashing_lights": true,
	"combo_stacking": true,
	"ghost_tapping": true,
	"framerate": 60,
	"vsync": false,
}

var _modifiers:Dictionary = {
	"note_speed": 0.0, #0 for default chart speed
	"song_pitch_speed": 1.0,
	"random_directions": false,
	"autoplay": false,
}

var _config:ConfigFile = ConfigFile.new()
const settings_path:String = "user://settings.cfg"

func save_settings():
	var err:Error = _config.load(settings_path)
	
	if err == OK:
		for pref in _prefs:
			_config.set_value("Preferences", pref, \
				_prefs[pref])
	
	_config.save(settings_path)

func load_settings():
	var err:Error = _config.load(settings_path)
	
	if err != OK:
		save_settings()
		return
	
	for pref in _prefs:
		if _config.has_section_key("Preferences", pref):
			_prefs[pref] = _config.get_value("Preferences", pref)
	
	update_prefs()

func update_prefs():
	Engine.max_fps = _prefs["framerate"]
	if _config.has_section_key("System", "volume"):
		AudioServer.set_bus_volume_db(0, _config.get_value("System", "volume"))
	
	var v_sync_mode = DisplayServer.VSYNC_DISABLED
	if _prefs["vsync"]: v_sync_mode = DisplayServer.VSYNC_ADAPTIVE
	DisplayServer.window_set_vsync_mode(v_sync_mode)

func get_setting(_name:String):
	if _prefs.has(_name):
		return _prefs[_name]
	return null

func set_setting(_name:String, value:Variant):
	if _prefs.has(_name):
		_prefs[_name] = value

func get_modifier(_name:String):
	if _modifiers.has(_name):
		return _modifiers[_name]
	return null

func set_modifier(_name:String, value:Variant):
	if _modifiers.has(_name):
		_modifiers[_name] = value
