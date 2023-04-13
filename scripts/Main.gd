extends Node2D

const DEF_MAX_FPS : int = 60

func _ready() -> void :
	Engine.max_fps = DEF_MAX_FPS
	# Change Current Scene to the Gameplay one
	switchScene("Gameplay")

func switchScene(newScene) -> void :
	print("Switching Scene to " + newScene + " Scene")
	get_tree().change_scene_to_file("res://scenes/" + newScene + ".tscn")
