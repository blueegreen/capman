extends Node2D

var pathfinder : Node2D
@onready var timer = $Timer

func _ready():
	pathfinder = get_node_or_null("pathfinder")
	timer.wait_time = GlobalVariables.time_step/2
	timer.start()

func _on_timer_timeout():
	pathfinder.reset()
