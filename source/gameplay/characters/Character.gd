class_name Character extends Node2D

var holdTimer:float = 0.0
var singDuration:float = 0.0

var is_player:bool = false # auto flipH and adjust offset if true

func playAnim(anim:String, speed:float = 1.0, from_end:bool = false):
	$AnimationPlayer.play(anim, -1, speed, from_end)
