extends Node

var current_scene : Node2D

func _ready():
	current_scene = get_tree().get_child(get_tree().get_child_count() - 1)
	GlobalTimer.wait_time = GlobalVariables.time_step
	GlobalTimer.start()
	GlobalTimer.timeout.emit()
