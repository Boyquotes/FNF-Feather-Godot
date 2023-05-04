extends Control

@onready var score_text:RichTextLabel = $"Score Text"
@onready var cpu_text:RichTextLabel = $"CPU Text"
@onready var health_bar:TextureProgressBar = $"Health Bar"
@onready var icon_PL:Sprite2D = $"Health Bar/iconPL"
@onready var icon_OPP:Sprite2D = $"Health Bar/iconOPP"

func update_health_bar(health:int):
	health = clamp(health, 0, 100)
	health_bar.value = health
	
	var health_bar_range:float = remap(health_bar.value, 0, 100, 100, 0)
	var health_bar_width:float = health_bar.texture_progress.get_size().x
	var icon_PL_width:float = icon_PL.texture.get_size().x
	var icon_OPP_width:float = icon_OPP.texture.get_size().x
	
	icon_PL.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_PL_width)+46
	icon_OPP.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_OPP_width)-36
	
	icon_PL.frame = 1 if health_bar.value < 20 else 0
	icon_OPP.frame = 1 if health_bar.value > 80 else 0
