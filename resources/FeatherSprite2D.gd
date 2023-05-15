# Attacheable Script for 2D Sprites with a few helpers
class_name FeatherSprite2D extends Sprite2D

var width:float:
	get: return texture.get_width()
var height:float:
	get: return texture.get_height()

var img_width:float:
	get: return texture.get_image().get_width()
var img_height:float:
	get: return texture.get_image().get_height()

@export var moving:bool = true

var velocity:Vector2 = Vector2.ZERO
var acceleration:Vector2 = Vector2.ZERO

func _process(delta:float):
	if moving: _process_motion(delta)

# Velocity and Acceleration Functions
# This implementation relies a lot on code from HaxeFlixel
# I ain't got a math degree so that's the best I can do
# @BeastlyGabi
func _process_motion(delta:float):
	var delta_vel:Vector2 = Vector2(
		0.5 * _compute_velocity(velocity.x, acceleration.x, delta) - velocity.x,
		0.5 * _compute_velocity(velocity.y, acceleration.y, delta) - velocity.y,
	)
	
	# set new velocity
	velocity += Vector2(delta_vel.x * 1.5, delta_vel.y * 1.5)
	# set up new position
	position += Vector2(
		velocity.x + delta_vel.x * delta,
		velocity.y + delta_vel.y * delta
	)

func _compute_velocity(vel:float, accel:float, delta:float):
	var true_delta:float = delta if accel != 0.0 else 0.0
	return vel + (accel * true_delta)
