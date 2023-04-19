class_name Character extends Node2D

var character:String = "bf"
var holdTimer:float = 0.0
var singDuration:float = 0.0
var is_player:bool = false

func _init(is_player:bool = false):
	self.is_player = is_player
	set_meta("is_player", self.is_player)

var sprite:AnimatedSprite2D
var animation:AnimationPlayer

func _ready():
	sprite = $Sprite
	animation = $AnimationPlayer
	
	# stupid stinky dumbass stuff from base game
	if is_player:
		sprite.flip_h = !sprite.flip_h
		if !character.begins_with("bf"): flipLR()
	elif character.begins_with("bf"): flipLR()

func flipLR(): pass

func playAnim(anim:String, speed:float = 1.0, from_end:bool = false):
	animation.play(anim, -1, speed, from_end)
