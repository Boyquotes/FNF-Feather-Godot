extends CanvasLayer

@onready var game = $"../"

@onready var score_text:Label = $"Score Text"
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

const score_div:String = " • "

func update_score_text():
	if score_text == null or game == null:
		return
	
	var actual_acc:float = game.accuracy * 100 / 100
	
	score_text.text = "SCORE: ["+str(game.score)+"]" \
	+score_div+"ACCURACY: ["+str("%.2f" % actual_acc)+"%]" \
	+score_div+"MISSES: ["+str(game.misses)+"]"
	
	if game.clear_type != "":
		score_text.text+=score_div+"["+game.clear_type+" - "+game.rank_str+"]"
	else:
		score_text.text+=score_div+"["+game.rank_str+"]"
	
	score_text.position.x = (Main.SCREEN["width"] * 0.5) - (score_text.size.x) / 2.0

func update_counter_text():
	if counter == null or game == null:
		return
	
	var counter_div:String = '\n'
	if Settings.get_setting("judgement_counter") == "horizontal":
		counter_div = score_div
	
	var tmp_txt:String = ""
	if game.notes_hit > 0:
		for i in game.judgements_gotten:
			tmp_txt+=i.to_pascal_case()+'s: '+str(game.judgements_gotten[i])
			if i != "shit": tmp_txt+=counter_div
		counter.text = tmp_txt
	else:
		counter.text = ""
	if Settings.get_setting("judgement_counter") == "horizontal":
		counter.position.x = (Main.SCREEN["width"] * 0.5) - (counter.size.x) / 2.2

# Judgement and Combo Popups
var show_judgements:bool = true
var show_combo_numbers:bool = true
var show_combo_sprite:bool = false
var show_milliseconds:bool = Settings.get_setting("show_ms")

func display_judgement(judge:String, color = null):
	if not show_judgements:
		return
	
	if not Settings.get_setting("combo_stacking"):
		# kill other judgements if they exist
		for j in game.judgement_group.get_children():
			j.queue_free()
	
	var judgement:FeatherSprite2D = FeatherSprite2D.new()
	judgement.texture = load(Paths.image("ui/base/ratings/"+judge))
	judgement.position.x += 30
	
	if color != null:
		judgement.modulate = color
	
	game.judgement_group.add_child(judgement)
	
	judgement.acceleration.y = 550
	judgement.velocity.y = -randi_range(140, 175)
	judgement.velocity.x = -randi_range(0, 10)
	
	if not Settings.get_setting("reduced_motion"):
		judgement.scale = Vector2(0.5, 0.5)
		get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) \
		.tween_property(judgement, "scale", Vector2(0.6, 0.6), 0.1)
	else:
		judgement.scale = Vector2(0.6, 0.6)
	
	get_tree().create_tween().tween_property(judgement, "modulate:a", 0, (Conductor.step_crochet) / 1000) \
	.set_delay((Conductor.crochet + Conductor.step_crochet * 2) / 1000) \
	.finished.connect(func(): judgement.queue_free())

func display_combo(combo:int, color = null):
	if not Settings.get_setting("combo_stacking"):
		# kill other combo objects if they exist
		for c in game.combo_group.get_children():
			c.queue_free()
	
	if not show_combo_numbers:
		return
	
	# split combo in half
	var combo_string:String = ("x" + str(combo)) if not combo < 0 else str(combo)
	var numbers:PackedStringArray = combo_string.split("")
	
	for i in numbers.size():
		var combo_num:FeatherSprite2D = FeatherSprite2D.new()
		combo_num.texture = load(Paths.image("ui/base/combo/num"+numbers[i]))
		combo_num.position.x = (35 * i) + last_judgement.position.x - 65
		combo_num.position.y = last_judgement.position.y + 125
		
		if color != null:
			combo_num.modulate = color
		
		# offset for new sprites woo
		if numbers[i] == 'x': combo_num.position.y += 15
		elif numbers[i] == '-': combo_num.position.y += 5
		
		game.combo_group.add_child(combo_num)
		
		combo_num.acceleration.y = randi_range(100, 200)
		combo_num.velocity.y = -randi_range(140, 160)
		combo_num.velocity.x = -randi_range(-5, 5)
		
		if not Settings.get_setting("reduced_motion"):
			combo_num.scale = Vector2(0.53, 0.53)
			get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC) \
			.tween_property(combo_num, "scale", Vector2(0.43, 0.43), 0.1)
		else:
			combo_num.scale = Vector2(0.43, 0.43)
		
		get_tree().create_tween() \
		.tween_property(combo_num, "modulate:a", 0, (Conductor.step_crochet * 2) / 1000) \
		.set_delay((Conductor.crochet) / 1000) \
		.finished.connect(func(): combo_num.queue_free())
	display_combo_sprite(color)

var last_judgement:FeatherSprite2D:
	get: return game.judgement_group.get_child(game.judgement_group.get_child_count() - 1)

var last_num:FeatherSprite2D:
	get: return game.combo_group.get_child(game.combo_group.get_child_count() - 1)

func display_combo_sprite(color = null):
	if not show_combo_sprite:
		return
	
	var combo_spr:FeatherSprite2D = FeatherSprite2D.new()
	combo_spr.texture = load(Paths.image("ui/base/ratings/combo"))
	combo_spr.scale = Vector2(0.45, 0.45)
	
	if last_judgement != null:
		combo_spr.position.x = last_judgement.position.x
		combo_spr.position.y = last_judgement.position.y + 60
	
	if color != null:
		combo_spr.modulate = color
	
	game.combo_group.add_child(combo_spr)
	
	combo_spr.acceleration.y = 600
	combo_spr.velocity.y = -150
	combo_spr.velocity.x = randi_range(1, 10)
	
	get_tree().create_tween() \
	.tween_property(combo_spr, "modulate:a", 0, (Conductor.step_crochet) / 1000) \
	.set_delay((Conductor.crochet + Conductor.step_crochet * 2) / 1000) \
	.finished.connect(func(): combo_spr.queue_free())

func display_milliseconds(milli_txt:String, color = null):
	if not show_milliseconds: return
	
	var milli_text:Alphabet = Alphabet.new()
	milli_text.bold = true
	milli_text.letter_size = 0.45
	milli_text.text = milli_txt
	
	if last_judgement != null:
		milli_text.position = Vector2(0, last_judgement.position.y + 200)
		milli_text.screen_center("X")
	
	if color != null:
		milli_text.modulate = color
	
	game.combo_group.add_child(milli_text)
	
	get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR) \
	.tween_property(milli_text, "modulate:a", 0, 0.50).finished.connect(milli_text.queue_free)
