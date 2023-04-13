extends Node2D

func _ready() -> void :
	$Music/Inst.play()

func _process(_delta) -> void :
	Conductor.songPosition = $Music/Inst.get_playback_position()
	pass

func _input(_iEvent) -> void :
	pass
