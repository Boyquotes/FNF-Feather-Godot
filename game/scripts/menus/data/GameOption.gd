class_name GameOption extends Resource

@export var name:StringName = "Placeholder"
@export var variable:String = "placeholder"
var value:Variant:
	set(v):
		if Settings.get_setting(variable) != null:
			Settings.set_setting(variable, v)
		else: pass