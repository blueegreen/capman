extends Node

var current_scene : Node2D

func _ready():
	GlobalTimer.wait_time = GlobalVariables.time_step
	GlobalTimer.start()
	GlobalTimer.timeout.emit()
