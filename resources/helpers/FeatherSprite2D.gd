# Attacheable Script for 2D Sprites with a few helpers
class_name FeatherSprite2D extends Sprite2D

var width:float:
	get: return texture.get_width()
var height:float:
	get: return texture.get_height()

var frame_width:float:
	get: return texture.get_image().get_width()
var frame_height:float:
	get: return texture.get_image().get_height()
