class_name NoteSkin extends Resource

const paths:Dictionary = {
	"noteskin_scenes": "res://game/gameplay/notes/",
	"strumline_scenes": "res://game/gameplay/strumline/",
	"noteskin_path": "res://assets/images/notes/",
}

@export var note_skin:String = "default"
@export var strum_skin:String = "default"

@export var note_scale:float = 0.7
@export var strum_scale:float = 0.7
@export var sustain_alpha:float = 0.6

# so this bullshit is here because sustain widths can be
# inaccurate with their respetive ends
# don't judge me
# hi swordcube
# @BeastlyGabi
@export var sustain_width_offset:float = 0

@export var note_antialiasing:bool = true
@export var strum_antialiasing:bool = true

func get_note_skin():
	var skin_base:String = note_skin
	
	var note_path:String = paths["noteskin_path"]+skin_base+"/arrows.res"
	if !ResourceLoader.exists(note_path): skin_base = "default"
	return note_path

func get_holds_path():
	var skin_base:String = note_skin
	
	var note_path:String = paths["noteskin_path"]+skin_base+"/sustain/"
	if !ResourceLoader.exists(note_path): skin_base = "default"
	return note_path

func get_strumline_skin():
	var skin_base:String = strum_skin
	
	var strum_path:String = paths["noteskin_path"]+skin_base+"/strum.res"
	if !ResourceLoader.exists(strum_path): skin_base = "default"
	return strum_path
