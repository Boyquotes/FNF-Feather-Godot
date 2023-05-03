extends Node

func getPath(append:String = ""):
	var return_folder:String = "res://assets"
	if append.length() > 0:
		return_folder += "/"+append
	return return_folder

func image(img:String):
	return getPath("images/")+img+".png"

func sound(snd:String):
	return getPath("sounds/")+snd+".ogg"
	
func sprite_res(spr:String, path:String = "images"):
	return getPath(path)+"/"+spr+".res"

func songs(song:String):
	return getPath("data/songs/")+song
