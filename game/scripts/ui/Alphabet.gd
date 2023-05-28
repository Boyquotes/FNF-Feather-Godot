class_name Alphabet extends ReferenceRect

var width:float = 0.0
var height:float = 0.0

var chars:Dictionary = {
	"letters": "abcdefghijklmnopqrstuvwxyz",
	"numbers": "0123456789",
	"symbols": "!@#$%&*()[]{}'`´~^.,;:/|\\?<>+-_=<>"
}

@export_category("Style")
@export var bold:bool = false
@export var letter_size:float = 1.0

@export_multiline var text:String:
	set(new_text):
		if text != new_text:
			text = new_text
			_on_change_text()

var menu_item:bool = false
var list_speed:float = 0.16
var vertical_spacing:int = 150
var id_off:Vector2 = Vector2(35, 0.28)
var force_X:float = -1
var disable_X:bool = false
var disable_Y:bool = false

var id:int = 0
var last_letters:Array[FeatherAnimatedSprite2D] = []

var _raw_text:String # internal

# func _init(_text:String, _bold:bool, x:float, y:float, _scale:float = 1):
#	# super._init()
#	position = Vector2(x, y)
#	scale = Vector2(_scale, _scale)
#	bold = _bold
#	text = _text

func _process(_delta):
	if menu_item:
		var lerp_speed:float = list_speed
		var remap_y:float = remap(id, 0, 1, 0, 1.1)
		var scroll:Vector2 = Vector2(
			force_X if force_X != -1 else lerpf(position.x, (id * id_off.x) + 100, lerp_speed),
			lerpf(position.y, (remap_y * vertical_spacing)+(Main.SCREEN["width"] * id_off.y), lerp_speed)
		)
		
		if !disable_X: position.x = scroll.x
		if !disable_Y: position.y = scroll.y

var offset_x:float = 0
var text_spaces:int = 0

func set_text():
	var _width:float = 0.0
	var _height:float = 0.0
	
	for txt in text.split(""):
		if txt == " " and txt == "_": text_spaces+=1
		
		if get_last_letter() != null:
			offset_x = get_last_letter().position.x+get_last_letter().width * letter_size
		
		if (text_spaces > 0):
			offset_x+=80 * text_spaces
		
		var is_let:bool = chars.get("letters").find(txt.to_lower()) != -1
		var is_num:bool = chars.get("numbers").find(txt.to_lower()) != -1
		var is_sym:bool = chars.get("symbols").find(txt.to_lower()) != -1
		
		var image_suffix:String = "normal"
		if bold: image_suffix = "bold"
		
		var let:FeatherAnimatedSprite2D = FeatherAnimatedSprite2D.new()
		let.sprite_frames = load("res://assets/images/ui/base/alphabet-"+image_suffix+".res")
		let.position = Vector2(offset_x, 0)
		let.apply_scale(Vector2(letter_size, letter_size))
		
		if is_let and txt != " ":
			var letter_anim:String = get_letter_anim(txt)
			let.offset = get_letter_offset(txt)
			let.play(letter_anim)
		else:
			let.visible = false
		
		_width += let.width
		add_child(let)
		last_letters.append(let)
		
		text_spaces = 0
		offset_x = 0
	
	width = _width
	height = get_last_letter().height


func get_letter_anim(txt:String):
	match txt:
		"-": "dash"
		"!": "exclamation"
		">": "greater"
		"<": "less"
		"\"": "left double quotes"
		".": "period"
		",": "comma"
		"+": "plus"
		"?": "question"
		"'": "single quotes"
		"*": "star"
		"=": "equals"
		"|": "pipe"
		_:
			if txt == " " or txt == null or txt == "": return " "
			if bold:
				return txt.to_upper()
			else:
				if txt.to_lower() != txt: return txt.to_upper() + " upper"
				else: return txt.to_upper() + " lower"

func get_letter_offset(txt:String):
	match txt:
		'.': return Vector2(-15, 25)
		_: return Vector2(0, 0)

func get_last_letter():
	if last_letters.size() > 0:
		return last_letters[last_letters.size() - 1]
	return null

func screen_center(axis:String):
	if not is_inside_tree(): return
	match axis.to_upper():
		"X": position.x = (Main.SCREEN["width"] - get_viewport_rect().position.x) / 3
		"Y": position.y = (Main.SCREEN["height"] - get_viewport_rect().position.y) / 2.5
		"XY": position = Vector2((Main.SCREEN["width"] - get_viewport_rect().position.x) / 3,
			(Main.SCREEN["height"] - get_viewport_rect().position.y) / 2.5)

func _on_change_text():
	while last_letters.size() -1 > 0:
		last_letters[0].queue_free()
		last_letters.erase(last_letters[0])
		remove_child(last_letters[0])
	last_letters = []
	set_text()
