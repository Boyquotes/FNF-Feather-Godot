extends Control

@onready var score_text:RichTextLabel = $"Score Text"
@onready var cpu_text:RichTextLabel = $"CPU Text"
@onready var health_bar:TextureProgressBar = $"Health Bar"
@onready var icon_PL:Sprite2D = $"Health Bar/iconPL"
@onready var icon_OPP:Sprite2D = $"Health Bar/iconOPP"

func update_health_bar(health:int):
	health = clamp(health, 0, 100)
	health_bar.value = health
	pass
