extends Node2D

var cur_selection:int = 0
var mods_list:PackedStringArray = []
var mod_group:Node

func _ready():
	mods_list = FeatherMod.list_mods()
	
	mod_group = Node.new()
	add_child(mod_group)
	
	for i in mods_list.size():
		if mods_list[i] == null: return
		
		var name_mod:String = mods_list[i].get_basename()
		var mod_entry:Alphabet = Alphabet.new(name_mod, true, 60, (70 * i) + 30)
		mod_entry.id = i
		mod_entry.menu_item = true
		mod_group.add_child(mod_entry)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Main.reset_scene()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Main.switch_scene("MainMenu", "game/scenes/menus")
