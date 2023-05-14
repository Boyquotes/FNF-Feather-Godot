extends CanvasLayer

@onready var score_text:RichTextLabel = $"Score Text"
@onready var cpu_text:RichTextLabel = $"CPU Text"
@onready var counter:Label = $"Counter"
@onready var health_bar:TextureProgressBar = $"Health Bar"
@onready var icon_PL:HealthIcon = $"Health Bar/Player"
@onready var icon_OPP:HealthIcon = $"Health Bar/Opponent"
@onready var timer_progress:Label = $"Time Progress"
@onready var timer_length:Label = $"Time Length"

var health_bar_width:float:
	get: return health_bar.texture_progress.get_size().x

func _ready():
	# this might be stupid but whatever
	match Settings.get_setting("judgement_counter"):
		"right":
			counter.position.x = 1185
		"horizontal":
			counter.position.x = Main.SCREEN["center"].x / 1.51
			if Settings.get_setting("downscroll"):
				counter.position.y = cpu_text.position.y + 165
			else:
				counter.position.y = 10
		"none": counter.queue_free()

func update_health_bar(delta:float, health:int):
	health = clamp(health, 0, 100)
	health_bar.value = health
	
	var health_bar_range:float = remap(health_bar.value, 0, 100, 100, 0)
	icon_PL.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_PL.width)-5
	icon_OPP.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_OPP.width)-75

	icon_PL.frame = 1 if health_bar.value < 20 else 0
	icon_OPP.frame = 1 if health_bar.value > 80 else 0