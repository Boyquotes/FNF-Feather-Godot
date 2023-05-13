class_name Judgement extends Resource

var name:String = "sick"
var score:int = 350
var accuracy:int = 100
var timing:float = 35.0
var health:int = 100

# Optional Stuff
var img:String = "sick"
var splash:bool = false

func _init(_name:String, _score:int, _accuracy:int, _timing:float, \
		_health:int, _splash:bool = false, _img:String = ""):
	
	# Push Judgement
	name = _name
	score = _score
	accuracy = _accuracy
	timing = _timing
	health = _health
	splash = _splash
	
	img = _img if _img.length() > 0 else _name
