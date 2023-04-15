extends Node2D
class_name BeatScene

func _ready():
	Conductor.connect("on_beat", func(beat : int): beatHit(beat))
	Conductor.connect("on_step", func(step : int): stepHit(step))
	Conductor.connect("on_sect", func(sect : int): sectHit(sect))
	
func beatHit(beat : int): pass
func stepHit(step : int): pass
func sectHit(sect : int): pass
