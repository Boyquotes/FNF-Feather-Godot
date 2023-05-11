class_name HealthIcon extends FeatherSprite2D

var attached:Alphabet
@export var icon_name:String = "face"

func _init(icon:String = "face"):
	icon_name = icon

func _ready():
	load_icon(icon_name)

func _process(_delta):
	if attached != null:
		position = Vector2(attached.position.x+attached.width+50+offset.x,
			attached.position.y+attached.height/5+offset.y)

func load_icon(icon:String):
	if ResourceLoader.exists(Paths.image("characters/icons/"+icon)):
		texture = load(Paths.image("characters/icons/"+icon))
	else:
		texture = load(Paths.image("characters/icons/face"))
