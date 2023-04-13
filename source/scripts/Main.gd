extends Node

const DEF_MAX_FPS : int = 60

func _ready() -> void :
	Engine.max_fps = DEF_MAX_FPS
	# Change Current Scene to the Gameplay one
	switchScene("Gameplay")

var volumes : Array[int] = [0, -5, -10, -15, -20, -25, -30, -35, -40, -45, -50]
var volumeInt : int = 2

var muted : bool = false

func _input(keyEvent : InputEvent) -> void :
	if keyEvent is InputEventKey:
		var oldVolume : int = volumes[volumeInt]
		var increase : int = 0
		if keyEvent.pressed:
			match (keyEvent.keycode):
				KEY_MINUS: increase = 1;
				KEY_EQUAL: increase = -1;
				KEY_0:
					muted = !muted
					var value : int = -50 if muted else oldVolume
					AudioServer.set_bus_volume_db(0, value)
					
		if increase != 0:
			volumeInt += increase
			# Wrap through the array values
			volumeInt = clamp(volumeInt, 0, len(volumes) - 1)
			AudioServer.set_bus_volume_db(0, volumes[volumeInt])
			oldVolume = volumes[volumeInt]
			# if increase == 1: $VolumeBeepUp.play()
			# if increase == -1: $VolumeBeepDown.play()
			increase = 0

func switchScene(newScene) -> void :
	print("Switching Scene to " + newScene + " Scene")
	get_tree().change_scene_to_file("res://source/scenes/" + newScene + ".tscn")
