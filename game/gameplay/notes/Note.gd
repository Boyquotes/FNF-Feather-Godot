class_name Note extends CanvasGroup

@export_category("Note Data")
@export var direction:int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
@export var time:float = 0.0 # Time in Milliseconds
@export var type:String = "default" # Time in Chart
@export var strum_line:int = 0 # Strumline that the note follows (set in chart)
@export var sustain_len:float = 0.0 # Sustain Tail Scale in Chart
@export var note_scale:float = 0.7 # Global Note Scale

@export_category("Type Properties")
@export var ignore_note:bool = false
@export var forces_miss:bool = false

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

var arrow:AnimatedSprite2D
var hold:Line2D

func _init(_time:float, _direction:int, _type:String = "default", _sustain_len:float = 0.0):
	super._init()
	time = _time
	direction = _direction
	sustain_len = _sustain_len
	type = _type
	
	if sustain_len > 0:
		is_sustain = true

func _ready():
	self.scale = Vector2(note_scale, note_scale)
	
	if arrow == null:
		arrow = AnimatedSprite2D.new()
		arrow.sprite_frames = load("res://assets/images/notes/default/default.res")
	arrow.play(Tools.cols[direction])
	add_child(arrow)

func _process(delta:float):
	var song_pos:float = Conductor.song_position
	can_be_hit = time > song_pos - 130.0 and time < song_pos + 160.0
	was_too_late = (time < song_pos - 160.0 and not was_good_hit)
	
	if sustain_len < 0:
		sustain_len = 0

func load_sustain():
	if sustain_len < 0:
		return
	
	var sustain_scale:float = sustain_len + Conductor.step_crochet/100*speed
	hold = Line2D.new()
	hold.texture = load("res://assets/images/notes/default/sustain/"+Tools.dirs[direction]+" hold piece.png")
	hold.width = 30
	#hold.points[0].y = sustain_scale
	add_child(hold)

func kill_sustain():
	if hold != null:
		hold.queue_free()

# scripted functions
func note_hit(player:bool): pass
func note_miss(player:bool): pass
