extends CanvasLayer

@onready var panel:ProgressBar = $Progress
@onready var sound:AudioStreamPlayer = $VolumeSound

var tween:Tween

func _ready():
	panel.value = Tools.game_volume

func show_panel():
	if tween != null: tween.stop()
	
	sound.play(0.0)
	panel.position.x = 5
	panel.value = Tools.game_volume
	
	# get out of here
	await(get_tree().create_timer(0.8).timeout)
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "position:x", -160.0, 0.4)
