extends Control

@onready var scoreText:RichTextLabel = $"Score Text"
@onready var cpuText:RichTextLabel = $"CPU Text"
@onready var healthBar:TextureProgressBar = $"Health Bar"
@onready var iconPL:Sprite2D = $"Health Bar/iconPL"
@onready var iconOPP:Sprite2D = $"Health Bar/iconOPP"

func update_healthBar(health:int):
	health = clamp(health, 0, 100)
	healthBar.value = health
	pass
