class_name FeatherMod extends Resource

@export_group("Mod General Metadata")
@export var name:String = "Friday Night Funkin'"
@export var state:String = "The base game, available as a mod file!"
@export var credits:Array[CreditsData] = [
	CreditsData.new("ninjamuffin99", "nm", "Programmer.", "", \
		Color.TOMATO, "https://twitter.com/ninja_muffin99"),
	CreditsData.new("PhantomArcade", "pa", "Animator.", "", \
		Color.TOMATO, "https://twitter.com/phantomarcade3k"),
	CreditsData.new("evilsk8er", "evil", "Artist.", "", \
		Color.TOMATO, ""),
	CreditsData.new("kawaisprite", "ks", "Musician.", "", \
		Color.TOMATO, "https://twitter.com/kawaisprite")
]

static func list_mods():
	var mod_dir:String = "user://mods/"
	var _mod_files:PackedStringArray = Tools.read_dir(mod_dir)
	var mods:PackedStringArray = []
	
	for i in _mod_files.size():
		if _mod_files[i].ends_with(".pck") or _mod_files[i].ends_with(".zip"):
			# var read_mod:FileAccess = FileAccess.open(_mod_files[i], FileAccess.READ)
			# print(read_mod)
			
			# if not mods.has(read_mod):
			#	mods.append(read_mod)
			
			mods.append(_mod_files[i])
	
	return mods
