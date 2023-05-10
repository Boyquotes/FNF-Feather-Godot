extends CanvasLayer

@onready var character:Character = $Character
@onready var game = get_tree().current_scene

func _ready():
	character.position = Vector2(game.player.position.x, game.player.position.y - 10)
	character.scale = game.player.scale
	
	SoundGroup.play_sound(Paths.sound("game/base/fnf_loss_sfx"))
	await(get_tree().create_timer(SoundGroup.get_sound_length()-2.8).timeout)
	SoundGroup.play_music(Paths.music("gameOver"))

func _process(_delta:float):
	if Input.is_action_just_pressed("ui_accept"):
		SoundGroup.stop_music()
		SoundGroup.play_sound(Paths.music("gameOverEnd"))
		await(get_tree().create_timer(SoundGroup.get_sound_length()-4.5).timeout)
		end_bullshit()
	

func end_bullshit():
	get_tree().paused = false
	Main.reset_scene()
	queue_free()
