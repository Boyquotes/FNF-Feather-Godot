extends BeatScene

var wacky_texts:Array = []

@onready var title_texts:CanvasLayer = $TitleTexts
@onready var newgrounds_sprite:Sprite2D = $NewgroundsSprite

@onready var background:ColorRect = $Background
@onready var foreground:ColorRect = $Foreground

@onready var gf_dance:AnimationPlayer = $"Girlfriend/Animation"
@onready var title_enter:AnimatedSprite2D = $"Title Enter"

func _ready():
	Main.change_rpc("TITLE SCREEN", "In the Menus")
	
	if SoundGroup.music.stream == null or not SoundGroup.music.playing:
		SoundGroup.play_music(Paths.music("freakyMenu"),-30.0, true)
		Conductor.change_bpm(100)
	
	wacky_texts = _get_wacky_texts()[randi_range(0, _get_wacky_texts().size() - 1)]

var ready_to_transition:bool = false

func _process(delta:float):
	if not SoundGroup.music.stream == null and SoundGroup.music.playing:
		Conductor.song_position = SoundGroup.music.get_playback_position() * 1000
		
		if SoundGroup.music.volume_db < 0.5:
			SoundGroup.music.volume_db += 50.0 * delta
	
	if skipped_intro:
		if not ready_to_transition: title_enter.play("Press Enter to Begin")
		
		if not ready_to_transition and Input.is_action_just_pressed("ui_accept"):
			ready_to_transition = true
			
			title_enter.play_anim("ENTER PRESSED", true)
			SoundGroup.play_sound(Paths.sound("confirmMenu"))
			scene_flash(1.0, Color8(255, 255, 255) if Settings.get_setting("flashing_lights") \
				else Color8(0, 0, 0))
			
			await(get_tree().create_timer(0.80).timeout)
			Main.switch_scene("MainMenu", "game/scenes/menus")
		
	if not skipped_intro and not ready_to_transition:
		if Input.is_action_just_pressed("ui_accept"):
			skip_intro()
			
			if SoundGroup.music.get_playback_position() != 9.3:
				SoundGroup.music.seek(9.3)

var danced:bool = false

func beat_hit(beat:int):
	$GameLogo.play("logo bumpin")
	
	if not $Girlfriend == null and not gf_dance == null and beat % 1 == 0:
		var direction:String = "Left" if not danced else "Right"
		gf_dance.play("dance" + direction)
		danced = not danced
	
	if skipped_intro: return
	
	match beat:
		1: _create_cool_text(["ninjamuffin99", "phantomarcade", "kawaisprite", "evilsk8r"])
		3: _add_cool_text("PRESENT")
		4: _delete_cool_text()
		5: _create_cool_text(["In partnership with"])
		7:
			_add_cool_text("NEWGROUNDS")
			newgrounds_sprite.visible = true
		8:
			_delete_cool_text()
			newgrounds_sprite.visible = false
		9: _create_cool_text([wacky_texts[0]])
		11: _add_cool_text(wacky_texts[1], Vector2(5, 60))
		12: _delete_cool_text()
		13: _add_cool_text("Friday", Vector2(0, 200))
		14: _add_cool_text("Night")
		15: _add_cool_text("Funkin")
		16: skip_intro()

var skipped_intro:bool = false
func skip_intro():
	if not skipped_intro:
		scene_flash(1.0, Color8(255, 255, 255) if Settings.get_setting("flashing_lights") \
			else Color8(0, 0, 0))
		
		remove_child(title_texts)
		remove_child(newgrounds_sprite)
		skipped_intro = true
		$Girlfriend.visible = true
		$GameLogo.visible = true
		title_enter.visible = true

func scene_flash(duration:int = 1.0, color_override = null):
	foreground.modulate.a = 1.0
	if not color_override == null: foreground.color = color_override
	get_tree().create_tween().tween_property(foreground, "modulate:a", 0.0, duration)

func _create_cool_text(texts_to_create:Array[String], offset:Vector2 = Vector2(0, 0)):
	for i in texts_to_create.size():
		var cool_text:Alphabet = $AlphabetTemp.duplicate()
		cool_text.text = texts_to_create[i]
		
		cool_text.screen_center("X")
		cool_text.position += Vector2(offset.x, (60 * i) + 200 + offset.y)
		title_texts.add_child(cool_text)

func _add_cool_text(new_text:String, offset:Vector2 = Vector2(0, 60)):
	var cool_text:Alphabet = $AlphabetTemp.duplicate()
	cool_text.text = new_text
	
	var last_text:Alphabet = cool_text
	if _last_text_group_member() != null:
		last_text = _last_text_group_member()
	
	cool_text.screen_center("X")
	cool_text.position += Vector2(offset.x, (last_text.position.y) + offset.y)
	title_texts.add_child(cool_text)

func _delete_cool_text():
	for letter in title_texts.get_children():
		title_texts.remove_child(letter)

func _last_text_group_member():
	if title_texts.get_child_count() > 0:
		var last:Alphabet = title_texts.get_children()[title_texts.get_child_count() - 1]
		return last
	return null

func _get_wacky_texts() -> Array[PackedStringArray]:
	var file:FileAccess = FileAccess.open("res://assets/introText.txt", FileAccess.READ)
	
	var swag_thing:Array[PackedStringArray] = []
	for i in file.get_as_text().split('\n'):
		swag_thing.append(i.split('--'))
	
	return swag_thing
