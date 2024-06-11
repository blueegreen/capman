extends Node

var time_step = 0.6
var tile_size = 128

func _ready():
	GlobalTimer.wait_time = time_step
	GlobalTimer.start()
