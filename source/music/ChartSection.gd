extends Resource
class_name ChartSection

# Copied from FNF with a few changes
var bpm : float = 0.0
var change_bpm : bool = false
var camera_position : int = 0 # 0 - BF | 1 - DAD | 2 - GF

var notes : Array[ChartNote] = []
var length_in_steps : int = 16
