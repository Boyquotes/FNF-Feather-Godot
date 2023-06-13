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
