# Attacheable Script for Animated 2D Sprites with a few helpers
class_name FeatherAnimatedSprite2D extends AnimatedSprite2D

var width:float:
	get: return sprite_frames.get_frame_texture(animation, 0).get_width()
var height:float:
	get: return sprite_frames.get_frame_texture(animation, 0).get_height()

var finished_playing:bool = false

var size:Vector2

func _ready():
	size = Vector2(
		sprite_frames.get_frame_texture(animation, 0).get_width(),
		sprite_frames.get_frame_texture(animation, 0).get_height()
	)
