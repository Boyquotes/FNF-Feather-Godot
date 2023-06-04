extends Node2D

var cur_selection:int = 0

@onready var credits_note:Node = $Credits_Node
@onready var icons_node:Node = $Icons_Node

@export var credits_list:Array[CreditsData] = []


func _ready():
	_reload_list(credits_list)
	update_selection()

func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
			Game.switch_scene("scenes/menus/MainMenu")
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		var is_up:bool = Input.is_action_just_pressed("ui_up")
		update_selection(-1 if is_up else 1)
	
	if Input.is_action_just_pressed("ui_accept"):
		if credits_list[cur_selection].url.length() > 0:
			OS.shell_open(credits_list[cur_selection].url)


var bg_tween:Tween


func update_selection(new_selection:int = 0):
	cur_selection = wrapi(cur_selection + new_selection, 0, credits_note.get_child_count())
	
	if not new_selection == 0:
		SoundHelper.play_sound("res://assets/sounds/scrollMenu.ogg")
	
	var bs:int = 0
	for item in credits_note.get_children():
		item.id = bs - cur_selection
		item.modulate.a = 1.0 if item.id == 0 else 0.6
		bs += 1
	
	if not bg_tween == null:
		bg_tween.stop()
	
	bg_tween = create_tween().set_ease(Tween.EASE_IN)
	bg_tween.tween_property($Background, "modulate", credits_list[cur_selection].color, 0.6)


func _reload_list(new_list:Array[CreditsData]):
	for i in new_list.size():
		var new_letter:Alphabet = $Alphabet_Template.duplicate()
		new_letter.text = new_list[i].user
		
		new_letter.menu_item = true
		new_letter.force_X = 180	
		new_letter.vertical_spacing = 110
		
		
		new_letter.id = i
		credits_note.add_child(new_letter)
		
		
		var icon:AttachedSprite2D = AttachedSprite2D.new()
		
		if ResourceLoader.exists("res://assets/images/menus/creditsMenu/" + new_list[i].icon + ".png"):
			icon.texture = load("res://assets/images/menus/creditsMenu/" + new_list[i].icon + ".png")
		else:
			icon.texture = load("res://assets/images/icons/face.png")
			icon.hframes = 2
		
		icon.position.x = new_list[i].icon_offset.x
		icon.tracker_position.y = new_list[i].icon_offset.y
		
		icon.use_spr_tracker_x = false
		icon.spr_tracker = new_letter
		icons_node.add_child(icon)
