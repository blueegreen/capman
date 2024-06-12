extends Node2D

@export var max_tile_count = 100
@onready var timer = $Timer

func _ready():
	timer.wait_time = GlobalVariables.time_step
	start()
	timer.start()

func start():
	var new_tile = preload("res://enemies/pathfinder_tile.tscn").instantiate()
	new_tile.global_position = global_position
	add_child(new_tile)
	new_tile.start()

func reset():
	print(timer.wait_time)
	for child in get_children():
		if child is Timer:
			continue
		child.free()
	start()

func _on_timer_timeout():
	reset()
