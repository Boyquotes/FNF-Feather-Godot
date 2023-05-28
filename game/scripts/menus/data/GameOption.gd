class_name GameOption extends Resource

@export var name:String = "Placeholder"
@export var variable:String = "placeholder"
@export var description:String = "..."
var value:Variant:
	get: return Settings.get_setting(variable)
	set(v):
		if Settings.get_setting(variable) != null:
			Settings.set_setting(variable, v)
@export var choices:Array = []

func _init(name:String, variable:String, description:String, choices:Array = []):
	self.name = name
	self.variable = variable
	self.description = description
	self.choices = choices
