class_name Judgement extends Resource

var name:String = "sick"
var score:int = 350
var accuracy:int = 100
var timing:float = 35.0
var health:int = 100

# Optional Stuff
var img:String = "sick"
var splash:bool = false

func _init(_name:String = "sick", _score:int = 350, \
		_accuracy:int = 100, _timing:float = 35.0, \
		_health:int = 100, _splash:bool = false, \
		_img:String = ""):
	
	# Push Judgement
	name = _name
	score = _score
	accuracy = _accuracy
	timing = _timing
	health = _health
	img = _img if _img.length() > 0 else _name

static func push_default():
	var judge_default:Judgement = Judgement.new()
	judge_default.splash = true
	return judge_default
