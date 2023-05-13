extends CanvasLayer

@onready var panel:ProgressBar = $Progress
@onready var sound:AudioStreamPlayer = $VolumeSound

var tween:Tween
var awaitTime:float = 0

func _ready():
	panel.value = Tools.game_volume

func show_panel():
	if tween != null: tween.stop()
	
	sound.play(0.0)
	panel.position.x = 5
	panel.value = Tools.game_volume
	
	awaitTime = 1.5

func _process(_delta:float):
	if (awaitTime > 0):
		awaitTime -= _delta
	elif (panel.position.x > -panel.size.x):
		panel.position.x -= 1000 * _delta
	
