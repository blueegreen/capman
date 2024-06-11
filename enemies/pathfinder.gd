extends Node2D

@export var max_tile_count = 100

func _ready():
	var new_tile = preload("res://enemies/pathfinder_tile.tscn").instantiate()
	new_tile.global_position = global_position
	add_child(new_tile)
	new_tile.start()
