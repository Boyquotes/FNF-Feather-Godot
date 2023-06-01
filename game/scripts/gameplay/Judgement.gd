class_name Judgement extends Resource

var name:String = "sick"

var score:int = 300
var health:int = 100
var accuracy:float = 1.0
var timing:float = 22.5

var img:String = name
var note_splash:bool = false

const timings:Dictionary = {
	"sick": 45.0,
	"good": 90.0,
	"bad": 135.0,
	"shit": 180.0
}

func _init(_name:String = "sick", _score:int = 300, _health:int = 100, _accuracy:float = 1.0, \
	_note_splash:bool = false, _img:String = ""):
	
	self.name = _name
	self.score = _score
	self.health = _health
	self.accuracy = _accuracy
	self.note_splash = _note_splash
	self.img = _img if not img == null and _img.length() > 0 else name
	
	self.timing = timings[name]
	
