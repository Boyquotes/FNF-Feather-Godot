class_name GameOption extends Resource

@export var option:String
@export var reference:String

var value:Variant:
	get: return Settings.get_setting(reference)
	set(v): Settings.set_setting(reference, v)
