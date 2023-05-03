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
			set_text(new_text)
			return new_text
		return new_text
var _raw_text:String # internal
@export var bold:bool = false

@export_category("Menu Item Settings")
@export var menu_item:bool = false
@export var list_speed:float = 0.16
@export var vertical_spacing:int = 150
@export var menu_offset:Vector2 = Vector2(35, 0.28)

var id:int = 0

var last_letters:Array[Letter] = []

func _init(text:String, x:float, y:float, size:float = 1):
	super._init()
	position.x = x
	position.y = y
	
	# self.size = size
	self.bold = bold
	# load text
	self.text = text

func _process(delta):
	if menu_item:
		var lerp_speed:float = list_speed
		var remap_y:float = remap(id, 0, 1, 0, 1.1)
		var scroll:Vector2 = Vector2(
			lerpf(position.x, (id * menu_offset.x) + 100, lerp_speed),
			lerpf(position.y, (remap_y * vertical_spacing) + (Main.GAME_SIZE.x * menu_offset.y), lerp_speed)
		)
		
		position.x = scroll.x
		position.y = scroll.y

var text_spaces:int = 0;
func set_text(new_text):
	var offset_x:float = 0;
	for txt in text.split(""):
		if txt == " " and txt == "_": text_spaces += 1
		var spc:String = ''
		
		if get_last_letter() != null:
			var last_width = get_last_letter().sprite_frames.get_frame_texture(get_last_letter().animation, get_last_letter().frame).get_width()
			offset_x = get_last_letter().position.x + last_width
		
		if (text_spaces > 0):
			offset_x += 40 * text_spaces
		text_spaces = 0
		
		var is_num:bool = chars.get("numbers").find(txt) > -1
		var is_sym:bool = chars.get("symbols").find(txt) > -1
		
		var let:Letter = Letter.new(offset_x, 0)
		let.load_sprite(txt, bold, is_num or is_sym)
		self.add_child(let)
		last_letters.append(let)
	

func get_last_letter():
	if last_letters.size() > 0:
		return last_letters[last_letters.size() - 1]
	return null

func screen_center(point:Array[int] = [Vector2.AXIS_X, Vector2.AXIS_Y]):
	if point.has(Vector2.AXIS_X):
		position.x = (Main.GAME_SIZE.x - get_viewport_rect().size.x) / 2
	if point.has(Vector2.AXIS_Y):
		position.y = (Main.GAME_SIZE.y - get_viewport_rect().size.y) / 2
