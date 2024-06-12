extends Node

var current_scene = null
var allowed_moves = 5
var move_list = Array()

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	GlobalTimer.wait_time = GlobalVariables.time_step
	GlobalTimer.start()
	GlobalTimer.timeout.emit()
