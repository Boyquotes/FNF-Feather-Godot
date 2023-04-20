extends Node

func getPath(append:String = ""):
	var return_folder:String = "res://assets"
	if append.length() > 0:
		return_folder += "/"+append
	return return_folder

func image(imageName:String):
	return getPath("images/")+imageName+".png"

func sound(audioName:String):
	return getPath("sounds/")+audioName+".ogg"

func songs(songName:String):
	return getPath("data/songs/")+songName
