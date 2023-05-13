class_name Note extends CanvasGroup

@export_category("Note Data")
@export var direction:int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
@export var time:float = 0.0 # Time in Milliseconds
@export var type:String = "default" # Time in Chart
@export var strum_line:int = 0 # Strumline that the note follows (set in chart)
@export var sustain_len:float = 0.0 # Sustain Tail Scale in Chart

@export_category("Type Properties")
@export var ignore_note:bool = false
@export var forces_miss:bool = false

@onready var strum:StrumLine = $"../../"

var is_sustain:bool = false # If the note is a hold note
var can_be_hit:bool = false # If the player can hit this note
var was_good_hit:bool = false # If this note has already been hit
var was_too_late:bool = false # If the player took to long too hit a note

var debug:bool = false

var must_press:bool:
	get: return strum_line == 1

var speed:float:
	get: return Conductor.scroll_speed

var width:float:
	get:
		var obj = hold if is_sustain else arrow
		if obj == null: return 0.0
		return obj.sprite_frames.get_frame_texture(obj.animation, 0).get_width()

var height:float:
	get:
		var obj = hold if is_sustain else arrow
		if obj == null: return 0.0
		return obj.sprite_frames.get_frame_texture(obj.animation, 0).get_height()

@onready var arrow:AnimatedSprite2D = $arrow
@onready var hold:Line2D = $hold
@onready var end:Sprite2D = $end

func _init(): # _time:float, _direction:int, _type:String = "default", _sustain_len:float = 0.0):
	super._init()
	# time = _time
	# direction = _direction
	# sustain_len = _sustain_len
	# type = _type

func _ready():
	if sustain_len > 0: is_sustain = true
	position = Vector2(-9999, -9999)
	
	var note_scale:float = strum.note_skin.note_scale
	var note_filter = TEXTURE_FILTER_NEAREST \
	if not strum.note_skin.note_antialiasing else TEXTURE_FILTER_LINEAR
	
	arrow.sprite_frames = load(strum.note_skin.get_note_skin())
	arrow.scale = Vector2(note_scale, note_scale)
	texture_filter = note_filter
	
	if sustain_len > 0:
		load_sustain()
	
	arrow.play(Tools.cols[direction])
	add_child(arrow)

func _process(delta:float):
	if is_sustain and hold != null:
		var downscroll_multiplier = -1 if Settings.get_setting("downscroll") else 1
		var sustain_scale:float = ((sustain_len / 2.5) * (speed * \
			Conductor.song_scale) / scale.y)
		
		hold.points = [Vector2.ZERO, Vector2(0, sustain_scale)]
		hold.modulate.a = strum.note_skin.sustain_alpha
		
		var very_last_point = hold.points.size()-1
		var end_point:float = (hold.points[very_last_point].y + ((end.texture.get_height() \
			* end.scale.y) / 2)) * downscroll_multiplier
		
		end.position = Vector2(hold.points[very_last_point].x, end_point)
		
		end.flip_v = downscroll_multiplier < 0
		end.modulate.a = hold.modulate.a
	
	var song_pos:float = Conductor.song_position
	var safe:float = Conductor.ms_threshold * (1.2 * Conductor.song_scale)
	
	can_be_hit = time > song_pos - safe and time < song_pos + safe
	was_too_late = (time < song_pos - safe and not was_good_hit)
	
	if sustain_len < 0:
		sustain_len = 0

func load_sustain():
	var hold_line:String = strum.note_skin.get_holds_path() \
	+Tools.dirs[direction]+" hold piece.png"
	var end_line:String = strum.note_skin.get_holds_path() \
	+Tools.dirs[direction]+" hold end.png"

	hold.texture = load(hold_line)
	end.texture = load(end_line)
	
	hold.visible = true
	end.visible = true
	
	hold.width = 35 + strum.note_skin.sustain_width_offset
	hold.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	if Settings.get_setting("downscroll"):
		hold.scale.y = -1
	end.position.y += hold.position.y / 2
	end.scale = arrow.scale

func kill_sustain():
	if hold != null: hold.queue_free()
	if end != null: end.queue_free()

# scripted functions
func note_hit(player:bool): pass
func note_miss(player:bool): pass
