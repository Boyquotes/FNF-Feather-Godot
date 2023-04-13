extends Node2D

func _ready() -> void :
	Conductor.startSong("test", 100)
	# pass

func _process(_delta : float) -> void :
	pass

func _input(_iEvent : InputEvent) -> void :
	pass
