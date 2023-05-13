class_name CreditsData extends Resource

@export_category("User Data")
@export var name:String = 'User'
@export var icon:String = 'user'
@export var profession:String = "placeholder"
@export var description:String = "placeholder."
@export var color:Color = Color.WHITE
@export var url:String = "https://example.com"

func _init(_name:String = 'User', _icon:String = 'user', \
	_profession:String = "placeholder", _description:String = "placeholder.", \
	_color:Color = Color.WHITE, _url:String = "https://example.com"):
	
	name = _name
	icon = _icon
	profession = _profession
	description = _description
	color = _color
	url = _url
	
