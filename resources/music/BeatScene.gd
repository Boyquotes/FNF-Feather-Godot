# Master Class for Song Events
class_name BeatScene extends Node2D

func _init():
	Conductor.on_beat.connect(beat_hit)
	Conductor.on_step.connect(step_hit)
	Conductor.on_sect.connect(sect_hit)

func beat_hit(_beat:int): pass
func step_hit(_step:int): pass
func sect_hit(_sect:int): pass
