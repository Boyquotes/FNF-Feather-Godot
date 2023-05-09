# Master Class for Song Events
class_name BeatScene extends Node2D

func _init():
	Conductor.on_beat.connect(beat_hit)
	Conductor.on_step.connect(step_hit)
	Conductor.on_sect.connect(sect_hit)
	Conductor._reset_music()

func beat_hit(beat:int): pass
func step_hit(step:int): pass
func sect_hit(sect:int): pass
