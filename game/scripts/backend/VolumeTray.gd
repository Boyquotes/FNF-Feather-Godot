extends CanvasLayer

func _ready():
	$ProgressBar.modulate.a = 0.0

var tween:Tween
func show_the_thing():
	$ProgressBar.value = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	$ProgressBar.modulate.a = 1.0
	if not tween == null:
		tween.stop()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($ProgressBar, "modulate:a", 0.0, 0.35).set_delay(0.85)

func _input(event:InputEvent):
	if Input.is_action_just_pressed("ui_volume_up") or Input.is_action_just_pressed("ui_volume_down"):
		var is_up:bool = Input.is_action_just_pressed("ui_volume_up")
		var value:float = 0.5 if is_up else -0.5
		var shift_thing:float = 0.0
		
		if Input.is_key_label_pressed(KEY_SHIFT):
			shift_thing = 4.0 if is_up else -4.0
			value = value + shift_thing
		
		var new_volume:float = clampf(AudioServer.get_bus_volume_db(0) + value, -49, 0)
		AudioServer.set_bus_volume_db(0, new_volume)
		SoundHelper.play_sound("res://assets/audio/sfx/scrollMenu.ogg")
		show_the_thing()
