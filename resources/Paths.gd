extends Node

func get_asset_path(append:String = ""):
	var return_folder:String = "res://assets"
	if append.length() > 0:
		return_folder+="/"+append
	return return_folder

func image(img:String, path:String = "images"):
	return get_asset_path(path)+"/"+img+".png"

func music(msc:String):
	return get_asset_path("music/")+msc+".ogg"

func sound(snd:String):
	return get_asset_path("sounds/")+snd+".ogg"

func sprite_res(spr:String, path:String = "images"):
	return get_asset_path(path)+"/"+spr+".res"

func songs(song:String):
	return get_asset_path("data/songs/")+song

func character_scene(char:String):
	return "res://game/scenes/gameplay/characters/"+char+".tscn"
