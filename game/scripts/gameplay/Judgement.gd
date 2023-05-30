class_name Judgement extends Resource

var name:String = "sick"
var score:int = 350
var accuracy:int = 100
var timing:float = 35.0
var health:int = 100

# Optional Stuff
var img:String = "sick"
var splash:bool = false

var timings:Dictionary= {
	"sick": 45.0, # 22.5
	#"great": 45.0
	"good": 90.0,
	"bad": 135.0,
	"shit": 180.0
}

func _init(_name:String, _score:int = 0, _accuracy:int = 0, \
		_health:int = 0, _splash:bool = false, _img:String = ""):
	
	# Push Judgement
	name = _name
	score = _score
	accuracy = _accuracy
	health = _health
	splash = _splash
	
	timing = timings[_name]
	
	img = _img if _img.length() > 0 else _name
