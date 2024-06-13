extends Node2D

@export var max_tile_count = 100
@onready var timer = $Timer
var player = null

func _ready():
	timer.wait_time = GlobalVariables.time_step / 2.0
	player = get_tree().get_nodes_in_group("player")[0]
	if player == null:
		queue_free()
		return
	start()
	timer.start()

func start():
	if player == null:
		queue_free()
		return
	var new_tile = preload("res://enemies/pathfinder_tile.tscn").instantiate()
	new_tile.global_position = player.end_pos
	add_child(new_tile)

func reset():
	for child in get_children():
		if child is Timer:
			continue
		child.free()
	start()

func _on_timer_timeout():
	reset()
