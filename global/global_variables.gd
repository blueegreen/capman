extends Node

var time_step = 0.7:
	set(value):
		if value != time_step:
			GlobalTimer.wait_time = value
			time_step = value
var tile_size = 128
