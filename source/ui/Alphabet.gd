class_name Alphabet extends CanvasGroup

var chars:Dictionary = {
	"letters": "abcdefghijklmnopqrstuvwxyz",
	"numbers": "0123456789",
	"symbols": "!@#$%&*()[]{}'`´~^.,;:/|\\?<>+-_=<>"
}

@export_category("Style")
@export var text:String:
	set(new_text):
		if new_text != text:
			text = new_text
			while last_letters.size() -1 > 0:
				last_letters[0].queue_free()
				last_letters.erase(last_letters[0])
				remove_child(last_letters[0])
			last_letters = []
			set_text()
		return new_text
var _raw_text:String # internal
@export var bold:bool = false

@export_category("Menu Item Settings")
@export var menu_item:bool = false
@export var list_speed:float = 0.16
@export var vertical_spacing:int = 150
@export var id_off:Vector2 = Vector2(35, 0.28)
@export var disable_X:bool = false
@export var disable_Y:bool = false

var id:int = 0
var last_letters:Array[Letter] = []

func _init(_text:String, _bold:bool, x:float, y:float, size:float = 1):
	super._init()
	position = Vector2(x, y)
	apply_scale(Vector2(size, size))
	bold = _bold
	text = _text

func _process(_delta):
	if menu_item:
		var lerp_speed:float = list_speed
		var remap_y:float = remap(id, 0, 1, 0, 1.1)
		var scroll:Vector2 = Vector2(
			lerpf(position.x, (id * id_off.x)+100, lerp_speed),
			lerpf(position.y, (remap_y * vertical_spacing)+(Main.GAME_SIZE.x * id_off.y), lerp_speed)
		)
		
		if !disable_X: position.x = scroll.x
		if !disable_Y: position.y = scroll.y

var offset_x:float = 0
var text_spaces:int = 0

func set_text():
	for txt in text.split(""):
		if txt == " " and txt == "_": text_spaces+=1
		
		if get_last_letter() != null:
			offset_x = get_last_letter().position.x+get_last_letter().width
		
		if (text_spaces > 0):
			offset_x+=80 * text_spaces
		
		var is_num:bool = chars.get("numbers").find(txt) > -1
		var is_sym:bool = chars.get("symbols").find(txt) > -1
		
		var let:Letter = Letter.new(offset_x, 0)
		let.load_sprite(txt, bold, is_num or is_sym)
		add_child(let)
		last_letters.append(let)
		
		text_spaces = 0
		offset_x = 0
	

func get_last_letter():
	if last_letters.size() > 0:
		return last_letters[last_letters.size() - 1]
	return null

func screen_center(axis:String):
	match axis.to_upper():
		"X": position.x = (Main.GAME_SIZE.x - get_viewport_rect().position.x) / 3
		"Y": position.y = (Main.GAME_SIZE.y - get_viewport_rect().position.y) / 2.5
		"XY": position = Vector2((Main.GAME_SIZE.x - get_viewport_rect().position.x) / 3,
			(Main.GAME_SIZE.y - get_viewport_rect().position.y) / 2.5)
