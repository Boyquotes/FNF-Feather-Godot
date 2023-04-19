# Master Class for Song Events
class_name BeatScene extends Node2D

func _init():
	Conductor.on_beat.connect(beatHit)
	Conductor.on_step.connect(stepHit)
	Conductor.on_sect.connect(sectHit)

func beatHit(beat:int): pass
func stepHit(step:int): pass
func sectHit(sect:int): pass
