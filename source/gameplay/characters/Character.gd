class_name Character extends Node2D

@export_category("Character Node")
@export var charName:String = "bf"
@export var hold_timer:float = 0.0
@export var sing_duration:float = 0.0
@export var is_player:bool = false

func _init(_is_player:bool = false):
	is_player = _is_player

var sprite:AnimatedSprite2D
var animation:AnimationPlayer

func _ready():
	sprite = $Sprite
	animation = $AnimationPlayer
	
	# stupid stinky dumbass stuff from base game
	if is_player:
		sprite.flip_h = !sprite.flip_h
		if !charName.begins_with("bf"): flip_lr()
	elif charName.begins_with("bf"): flip_lr()

func flip_lr(): pass

func play_anim(anim:String, speed:float = 1.0, from_end:bool = false):
	animation.play(anim, -1, speed, from_end)
	
var to_left:bool = false

func dance():
	#if animation.find_animation(animation.get_animation("danceLeft")) != null:
	#	var anim:String = "danceRight"
	#	if to_left: anim = "danceLeft"
	#	play_anim(anim)
	# else:
		play_anim("idle")
