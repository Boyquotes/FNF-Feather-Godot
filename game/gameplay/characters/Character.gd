class_name Character extends CanvasGroup

@export_category("Character Node")
@export var character_name:String = "bf"
@export var icon_name:StringName = "face"
@export var sing_duration:float = 4.0
@export var bopping_time:int = 2
@export var camera_offset:Vector2 = Vector2.ZERO
@export var is_player:bool = false

var hold_timer:float = 0.0
var is_flipped:bool = false
var finished_playing:bool = false

var size:Vector2
var midpoint:Vector2

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var animation:AnimationPlayer = $AnimationPlayer
var last_anim:String = "idle"

func _ready():
	if !is_player:
		if character_name.begins_with("bf"):
			sprite.flip_h = !sprite.flip_h
			is_flipped = true
	
	animation.animation_finished.connect(func(name:StringName): finished_playing = true)
	dance(true)
	
	if animation != null:
		size = Vector2(
			sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_width(),
			sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()
		)
		midpoint = get_mid()

func _process(delta:float):
	if not is_player:
		if is_singing():
			hold_timer += delta
		
		if hold_timer >= Conductor.step_crochet * sing_duration * 0.0011:
			dance()
			hold_timer = 0
	else:
		hold_timer += delta if is_singing() else 0
		if is_missing() and finished_playing:
			dance(true)

func get_mid():
	return Vector2(sprite.position.x + size.x * 0.5, sprite.position.y + size.y * 0.5)

func get_camera_midpoint():
	var vec:Vector2 = position
	vec.x += sprite.position.x
	vec.y += sprite.position.y
	return vec

func play_anim(anim:String, forced:bool = false, speed:float = 1.0, from_end:bool = false):
	if is_flipped:
		if anim == "singLEFT": anim = "singRIGHT"
		elif anim == "singRIGHT": anim = "singLEFT"
	
	if not animation.has_animation(anim):
		return
	
	if forced or last_anim != anim or finished_playing:
		if forced:
			animation.seek(0.0)
			sprite.frame = 0
		
		last_anim = anim
		finished_playing = false
		animation.play(anim, -1, speed, from_end)

var to_left:bool = false

func dance(forced:bool = false):
	#if animation.has_animation("danceLeft"):
	#	var anim:String = "danceRight"
	#	if to_left: anim = "danceLeft"
	#	play_anim(anim, forced)
	# else:
	play_anim("idle", forced)

func is_singing(): return animation.current_animation.begins_with("sing")
func is_missing(): return animation.current_animation.ends_with("miss")
