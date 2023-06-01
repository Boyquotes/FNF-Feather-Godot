class_name MusicBeatNode2D extends Node2D

var cur_step:int:
	get: return Conductor.step_position

var cur_beat:int:
	get: return Conductor.beat_position

var cur_bar:int:
	get: return Conductor.bar_position


func _init():
	Conductor.reset()
	
	Conductor.step_caller.connect(on_step)
	Conductor.beat_caller.connect(on_beat)
	Conductor.bar_caller.connect(on_bar)

func on_step(step:int): pass
func on_beat(beat:int): pass
func on_bar(bar:int): pass
