extends Node

var _prefs:Dictionary = {
	# Gameplay
	"downscroll": false, # Sets your Strumline's Vertical Position to the bottom
	"center_notes": false, # Sets your Strumline's Position to the Center of the Screen
	"ghost_tapping": true, # Tapping when there's no notes to hit won't punish you

	"note_speed": 0.0, # Define your Custom Scroll Speed | 0 = Chart Speed

	"framerate": 60, # Define the maximum framerate the game can go
	"v_sync": false, # Eliminates screen tearing by limiting your GPU's Framerate

	# Customization
	"rating_counter": "left", # If set to a direction, a counter which counts rating amounts will be whown
	"ratings_on_hud": false, # Locks the Ratings on the HUD

	# the following only work if "judgements_on_hud" is enabled
	"rating_position": [0.0, 0.0],
	"combo_position": [0.0, 0.0],

	# Default, Quant, Etc. . .
	"note_skin": "default", # Define your Note's Appearance
}

func get_pref(_name:String): return _prefs[_name]
func set_pref(_name:String, value:Variant): _prefs[_name] = value
