class_name GameOption extends Resource

@export var name:StringName = "Placeholder"
@export var variable:String = "placeholder"
var value:Variant:
	set(v):
		if Preferences.get_pref(variable) != null:
			Preferences.set_pref(variable, v)
		else: pass
