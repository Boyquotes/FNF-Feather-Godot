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
	match Preferences.get_pref("rating_counter"):
		"none": counter.queue_free()
		_: pass

func update_health_bar(health:int):
	health = clamp(health, 0, 100)
	health_bar.value = health
	
	var health_bar_range:float = remap(health_bar.value, 0, 100, 100, 0)
	var icon_PL_width:float = icon_PL.texture.get_size().x
	var icon_OPP_width:float = icon_OPP.texture.get_size().x
	
	icon_PL.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_PL_width)-5
	icon_OPP.position.x = health_bar.position.x+((health_bar_width*(health_bar_range) * 0.01)-icon_OPP_width)-75
	
	icon_PL.frame = 1 if health_bar.value < 20 else 0
	icon_OPP.frame = 1 if health_bar.value > 80 else 0

func icons_bounce(beat:int = -1):
	var icon_scale:float = 1.5
	var scale_vec:Vector2 = Vector2(icon_scale, icon_scale)
	
	for i in [icon_PL, icon_OPP]:
		if beat <= 0 and i.scale.x != 0.875:
			var i_lerp:float = lerpf(icon_scale, 1, 1.25)
			i.scale = Vector2(i_lerp, i_lerp)
		elif beat > 0:
			i.scale = scale_vec
