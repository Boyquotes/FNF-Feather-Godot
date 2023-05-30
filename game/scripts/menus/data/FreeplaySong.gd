class_name FreeplaySong extends Resource

@export_category("Song Data")
@export var name:String = 'Test'
@export var folder:String = 'test'
@export var color:Color = Color.WHITE
@export var difficulties:Array[String] = ["easy", "normal", "hard"]

@export_subgroup("Icon Data")
@export var icon:String = 'bf'
@export var icon_frames:int = 2
