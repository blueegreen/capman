extends Node

var time_step = 0.7:
	set(value):
		if value != time_step:
			GlobalTimer.wait_time = value
			time_step = value
var tile_size = 128
var levels = Array()
var highscores = Array()

func _ready():
	levels.resize(100)
	highscores.resize(100)
	levels.fill(false)
	highscores.fill(1001)
	levels[1] = true
