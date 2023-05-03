extends Node2D

var cur_selection:int = 0

@onready var bg:Sprite2D = $Background
@export var users:Array[CreditsData] = []
var credits_group:AlphabetNode
var category_label:Alphabet

var local_queue:Array[String] = []

func _ready():
	credits_group = AlphabetNode.new()
	add_child(credits_group)
	
	category_label = Alphabet.new("TEST", 0, 0)
	category_label.apply_scale(Vector2(0.7, 0.7))
	category_label.position.x = (Main.GAME_SIZE.x - category_label.get_global_transform_with_canvas().origin.x) / 2
	category_label.position.y = get_screen_transform().origin.y + 25
	add_child(category_label)
	
	for i in users.size():
		if users[i] == null: return
		var user_entry:Alphabet = Alphabet.new(users[i].name, 0, 60 * i)
		user_entry.id = i
		user_entry.menu_item = true
		user_entry.vertical_spacing = 110
		credits_group.add_child(user_entry)
		
	update_selection()

func _process(delta):
	pass

func _input(keyEvent:InputEvent):
	if keyEvent is InputEventKey and keyEvent.pressed:
		match keyEvent.keycode:
			KEY_UP: update_selection(-1)
			KEY_DOWN: update_selection(1)
			KEY_LEFT: return
			KEY_RIGHT: return
			KEY_CTRL: return
			KEY_ALT: return
			KEY_ENTER: return
			KEY_ESCAPE: Main.switch_scene("menus/MainMenu")

var bg_tween:Tween
func update_selection(new_selection:int = 0):
	cur_selection = clampi(cur_selection + new_selection, 0, users.size() -1)
	#$scroll_sound.play(0.0)
	update_list_items()
	bg_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	bg_tween.tween_property(bg, "modulate", users[cur_selection].color, 0.8)

func update_list_items():
	var bs:int = 0
	for item in credits_group.get_children():
		item.id = bs - cur_selection
		item.modulate = Color.LIME if local_queue.has(item._raw_text) else Color.WHITE
		item.modulate.a = 1 if item.id == 0 else 0.7
		bs += 1
