extends Node

var _prefs:Dictionary = {
	### GAMEPLAY ###
	"downscroll": true,
	"centered_receptors": false,
	"ghost_tapping": true,
	"note_speed": 0.0, #0 for default chart speed
	"note_offset": 0.0,
	
	### VISUAL ###
	"note_quantization": false,
	"judgement_counter": false,
	"show_keybinds": true,
	
	"flashing_lights": true,
	"combo_stacking": true,
	"cpu_receptors": true,
	"opaque_sustains": false,
	"note_splashes": true,
	
	### BEHAVIOR ###
	"timing_preset": "etterna",
	"combo_break_judgement": "miss",
	"song_pitch": 1.0,
	
	### OTHER ###
	"framerate": 60,
	"vsync": true,
}

var _controls:Dictionary = {
	"note_left": ["A", "LEFT"],
	"note_down": ["S", "DOWN"],
	"note_up": ["W", "UP"],
	"note_right": ["D", "RIGHT"],
	
	"ui_left": ["A", "LEFT"],
	"ui_down": ["S", "DOWN"],
	"ui_up": ["W", "UP"],
	"ui_right": ["D", "RIGHT"],
	
	"ui_accept": ["ENTER", "SPACE"],
	"ui_cancel": ["ESCAPE", "BACKSPACE"],
	"ui_pause": ["ENTER", "ESCAPE"],
	
	"ui_volume_up": ["EQUAL", "KP ADD"],
	"ui_volume_down": ["MINUS", "KP SUBTRACT"],
}

var _config:ConfigFile = ConfigFile.new()
const settings_path:String = "user://settings.cfg"

func save_settings():
	var err:Error = _config.load(settings_path)
	
	if err == OK:
		for pref in _prefs:
			_config.set_value("Preferences", pref, _prefs[pref])
	
	_config.save(settings_path)

func save_controls():
	var err:Error = _config.load(settings_path)
	
	if err == OK:
		for key in _controls:
			_config.set_value("Controls", key, _controls[key])
	
	_config.save(settings_path)

func load_settings():
	var err:Error = _config.load(settings_path)
	
	if not err == OK:
		save_settings()
		return
	
	for pref in _prefs:
		if _config.has_section_key("Preferences", pref):
			_prefs[pref] = _config.get_value("Preferences", pref)
	
	load_controls()
	update_prefs()

func update_prefs():
	Engine.max_fps = _prefs["framerate"]
	if _config.has_section_key("System", "volume"):
		AudioServer.set_bus_volume_db(0, _config.get_value("System", "volume"))
	
	var v_sync_mode = DisplayServer.VSYNC_DISABLED
	if _prefs["vsync"]: v_sync_mode = DisplayServer.VSYNC_ADAPTIVE
	DisplayServer.window_set_vsync_mode(v_sync_mode)

func load_controls():
	var err:Error = _config.load(settings_path)
	
	for key in _controls:
		if err == OK:
			if _config.has_section_key("Controls", key):
				_controls[key] = _config.get_value("Controls", key)
		refresh_keys(key)


func refresh_keys(key:String):
	var key_mapper:Array[InputEvent] = InputMap.action_get_events(key)
	var key1:InputEventKey = InputEventKey.new()
	var key2:InputEventKey = InputEventKey.new()
	
	key1.set_keycode(OS.find_keycode_from_string(_controls[key][0]))
	key2.set_keycode(OS.find_keycode_from_string(_controls[key][1]))
	
	if not key_mapper.size() - 1 == -1:
		for i in key_mapper:
			InputMap.action_erase_event(key, i)
	else:
		InputMap.add_action(key)
	
	InputMap.action_add_event(key, key1)
	InputMap.action_add_event(key, key2)

func get_setting(_name:String):
	if _prefs.has(_name):
		return _prefs[_name]
	return null

func set_setting(_name:String, value:Variant):
	if _prefs.has(_name):
		_prefs[_name] = value
