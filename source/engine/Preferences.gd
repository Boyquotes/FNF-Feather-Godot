extends Node

# Gameplay
var down_scroll:bool = false # Sets your Strumline's Vertical Position to the bottom
var center_notes:bool = false # Sets your Strumline's Position to the Center of the Screen
var ghost_tapping:bool = false # Tapping when there's no notes to hit won't punish you

var note_speed:float = 0.0 # Define your Custom Scroll Speed | 0 = Chart Speed

# Customization
var judgements_on_hud:bool = false # Locks the Judgements on the HUD

# the following only work if "judgements_on_hud" is enabled
var rating_position:Array[float] = [0.0, 0.0]
var combo_position:Array[float] = [0.0, 0.0]

# Default, Quant, Etc. . .
var note_skin:String = "default" # Define your Note's Appearance

const dumb_mode:bool = false # Makes the game dumb
