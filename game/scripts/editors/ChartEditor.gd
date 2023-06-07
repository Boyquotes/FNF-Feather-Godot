extends MusicBeatNode2D


func _ready():
	pass


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.switch_scene("scenes/gameplay/Gameplay")
