class_name ChartSection extends Resource

# Copied from FNF with a few changes
var bpm:float = 0.0
var change_bpm:bool = false
var camera_position:int = 0 # 0 - BF | 1 - DAD | 2 - GF
var animation:String = ""

var notes:Array[ChartNote] = []
var length_in_steps:int = 16
