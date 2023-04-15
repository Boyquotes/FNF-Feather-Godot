extends Node

const DEF_MAX_FPS : int = 60

func _ready():
	Engine.max_fps = DEF_MAX_FPS
	# Change Current Scene to the Gameplay one
	switch_scene("menus/MainMenu")

var muted : bool = false

var volume : int = 0.5

func _input(keyEvent : InputEvent):
	if keyEvent is InputEventKey:
		var oldVolume : int = 0.5
		if keyEvent.pressed:
			match keyEvent.keycode:
				KEY_MINUS: volume -= 0.5;
				KEY_EQUAL: volume += 0.5;
				KEY_0:
					muted = !muted
					var value : int = -50 if muted else oldVolume
					AudioServer.set_bus_volume_db(0, value)
				KEY_8: Main.switch_scene("tools/convert/TXT Converter")
				KEY_9: Main.switch_scene("tools/convert/XML Converter")
					
		if volume != oldVolume:
			volume = clamp(volume, 0, 1)
			oldVolume = AudioServer.get_bus_volume_db(linear_to_db(volume))
			AudioServer.set_bus_volume_db(0, linear_to_db(volume))
			#if increase == -1: $VolumeBar/VolumeUpSound.play()
			#if increase == 1: $VolumeBar/VolumeDownSound.play()
			volume = 0

func switch_scene(newScene : String):
	print("Switching Scene to " + newScene + " Scene")
	get_tree().change_scene_to_file("res://source/" + newScene + ".tscn")
