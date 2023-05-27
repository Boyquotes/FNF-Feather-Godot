extends CanvasLayer

@onready var game = $"../"

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
	
	update_score_text()
	update_counter_text()

func update_health_bar(health:int):
	health = clamp(health, 0, 100)
	health_bar.value = health
	
	icon_PL.position.x = health_bar.position.x+((health_bar_width*(1 - health_bar.value / 100)) - icon_PL.width) - 5
	icon_OPP.position.x = health_bar.position.x+((health_bar_width*(1 - health_bar.value / 100)) - icon_OPP.width) - 75

	icon_PL.frame = 1 if health_bar.value < 20 else 0
	icon_OPP.frame = 1 if health_bar.value > 80 else 0

const score_div:String = " / " # " • "

func update_score_text():
	if game.notes_hit == 0 or game == null:
		score_text.text = ""
		return
	
	var actual_acc:float = game.accuracy * 100 / 100
	
	var tmp_txt:String = "MISSES: ["+str(game.misses)+"]" if not \
		Settings.get_setting("misses_over_score") \
			else "SCORE: ["+str(game.score)+"]"
	
	tmp_txt+=score_div+"ACCURACY: ["+str("%.2f" % actual_acc)+"%]"
	
	if game.get_clear_type() != "":
		tmp_txt+=score_div+"["+game.get_clear_type()+" - "+game.rank_str+"]"
	else:
		tmp_txt+=score_div+"["+game.rank_str+"]"
	
	# Use "bbcode_text" instead of "text"
	score_text.bbcode_text = tmp_txt
	score_text.position.x = (Main.SCREEN["width"] * 0.5) - (score_text.get_content_width()) / 2.0

func update_counter_text():
	if counter == null:
		return
	
	var counter_div:String = '\n'
	if Settings.get_setting("judgement_counter") == "horizontal":
		counter_div = score_div
	
	var tmp_txt:String = ""
	for i in game.judgements_gotten:
		tmp_txt+=i.to_pascal_case()+'s: '+str(game.judgements_gotten[i])
		if i != "shit": tmp_txt+=counter_div
	
	if not Settings.get_setting("misses_over_score"):
		tmp_txt+=counter_div+"Misses: "+str(game.misses)
	
	counter.text = tmp_txt
	if Settings.get_setting("judgement_counter") == "horizontal":
		counter.position.x = (Main.SCREEN["width"] * 0.5) - (counter.size.x) / 2.2
