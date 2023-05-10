class_name Letter extends FeatherAnimatedSprite2D

var letter:String = ''

func _init(x_pos:float, y_pos:float):
	sprite_frames = load(Paths.sprite_res("ui/base/alphabet"))
	position = Vector2(x_pos, y_pos)
	
func load_sprite(txt:String, bold:bool, _spc:bool = false):
	self.letter = txt
	if txt == " ":
		modulate.a = 0
		return
	
	var actualAnim:String = get_anim(txt)
	if !_spc:
		if bold: actualAnim+=" bold"
		elif txt.to_lower() != txt: actualAnim+=" capital"
		else: actualAnim+=" lowercase"
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
		'.':
			offset.x-=15
			offset.y+=25
			return 'period'
		',': return 'comma'
		_: return txt.to_upper()
