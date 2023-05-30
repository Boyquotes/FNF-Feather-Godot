# Attacheable Script for Animated 2D Sprites with a few helpers
class_name FeatherAnimatedSprite2D extends AnimatedSprite2D

var width:float:
	get: return sprite_frames.get_frame_texture(animation, 0).get_width()
var height:float:
	get: return sprite_frames.get_frame_texture(animation, 0).get_height()

var finished_playing:bool = false

var size:Vector2:
	get:
		return Vector2(
			sprite_frames.get_frame_texture(animation, 0).get_width(),
			sprite_frames.get_frame_texture(animation, 0).get_height()
		)

var last_anim:String

func play_anim(anim:String, forced:bool = false, speed:float = 1.0, from_end:bool = false):
	if forced or last_anim != anim or finished_playing:
		if forced: frame = 0
		
		last_anim = anim
		finished_playing = false
		play(anim, 1.0, false)
