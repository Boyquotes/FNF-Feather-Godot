class_name Note extends CanvasGroup

@export_category("Note Data")
@export var direction:int = 0 # 0: Purple | 1: Blue | 2: Green | 3: Red
@export var time:float = 0.0 # Time in Milliseconds
@export var type:String = "default" # Time in Chart
@export var strumLine:int = 0 # Strumline that the note follows (set in chart)
@export var sustain_len:float = 0.0 # Sustain Tail Scale in Chart
@export var arrow_tex:SpriteFrames = load(Paths.sprite_res("notes/default/default"))
@export var hold_tex:SpriteFrames = arrow_tex

@export_category("Type Properties")
@export var ignore_note:bool = false
@export var forces_miss:bool = false

@export_category("Gameplay Values")
@export var is_sustain:bool = false # If the note is a hold note
var is_sustain_end:bool = false # internal, if the hold note has reached the end
@export var can_be_hit:bool = false # If the player can hit this note
@export var was_good_hit:bool = false # If this note has already been hit
@export var was_too_late:bool = false # If the player took to long too hit a note

var player_note:bool:
	get: return true if strumLine == 1 else false

var arrow:AnimatedSprite2D
var hold:AnimatedSprite2D
var end:AnimatedSprite2D

func _init(_time:float, _direction:int, _type:String = "default"):
	super._init()
	time = _time
	direction = _direction
	type = _type

func _ready():
	arrow = AnimatedSprite2D.new()
	arrow.sprite_frames = arrow_tex
	arrow.apply_scale(Vector2(0.7, 0.7))
	# load_sustain()
	add_child(arrow)

func reset_anim(col:String):
	if arrow != null: arrow.play(col)
	if hold != null: hold.play(col+" hold piece")
	if end != null: end.play(col+" hold end")
	
func _process(delta:float):
	var song_pos:float = Conductor.song_position
	can_be_hit = time > song_pos - 130.0 and time < song_pos + 160.0
	# was_too_late = (time < song_pos + Conductor.safe_zone and not was_good_hit)
	# print('hit note:'+str(can_be_hit))

func load_sustain():
	if sustain_len < 1: return
	hold = AnimatedSprite2D.new()
	hold.sprite_frames = hold_tex
	hold.modulate.a = 0.6
	
	var sustain_scale:float = sustain_len+((Conductor.step_crochet / 100) * Conductor.scroll_speed)
	hold.apply_scale(Vector2(0.7, 0.7 * sustain_scale))
	hold.position = Vector2(arrow.position.x+arrow.get_viewport_rect().position.x,
		arrow.position.y - Conductor.bpm)
	add_child(hold)
	
	end = AnimatedSprite2D.new()
	var end_y:float = hold.position.y - ((Conductor.bpm) - 1.5 * Conductor.scroll_speed)
	end.position = Vector2(hold.position.x+hold.get_viewport_rect().position.x, end_y)
	end.flip_v = true
	end.sprite_frames = hold_tex
	end.modulate.a = hold.modulate.a
	end.apply_scale(Vector2(0.7, 0.7))
	add_child(end)
