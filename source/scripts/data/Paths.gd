extends Node

func getPath(append : String = ""):
	var returnFolder : String = "res://assets"
	if append.length() > 0:
		returnFolder += "/" + append
	return returnFolder

func image(imageName : String):
	return getPath("images/") + imageName + ".png"

func sound(audioName : String):
	return getPath("sounds/") + audioName + ".ogg"

func songs(songName : String):
	return getPath("data/songs/") + songName
