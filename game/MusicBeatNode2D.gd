class_name MusicBeatNode2D extends Node2D

var cur_step:int:
	get: return Conductor.step_position

var cur_beat:int:
	get: return Conductor.beat_position

var cur_sect:int:
	get: return Conductor.sect_position


func _init():
	Conductor.reset()
	
	Conductor.step_caller.connect(on_step)
	Conductor.beat_caller.connect(on_beat)
	Conductor.sect_caller.connect(on_sect)

func on_step(step:int): pass
func on_beat(beat:int): pass
func on_sect(sect:int): pass
