class_name Letter extends AnimatedSprite2D

var letter:String = ''
var bold:bool = false

func _init(x_pos:float, y_pos:float):
	sprite_frames = load(Paths.sprite_res("ui/base/alphabet"))
	position.x = x_pos
	position.y = y_pos
	
func load_sprite(txt:String, bold:bool, _spc:bool = false):
	self.letter = txt
	self.bold = bold
	if txt == " ": modulate.a = 0
	var actualAnim:String = get_anim(txt)
	if !_spc: actualAnim +=  " bold"
	play(actualAnim)

func get_anim(txt:String):
	match txt:
		'#': return 'hashtag'
		'&': return 'amp'
		'😠': return 'angry faic'
		'♥': return 'heart'
		'$': return 'dollarsign '
		'?': return 'question mark'
		'!': return 'exclamation point'
		'<': return 'lessThan'
		'>': return 'greaterThan'
		"\'", "'": return "apostraphie"
		'.': return 'period'
		',': return 'comma'
		_: return txt.to_upper()
