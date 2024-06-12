extends Area2D

@onready var forward_cast = $forward_cast
@onready var left_cast = $left_cast
@onready var right_cast = $right_cast
@onready var back_cast = $back_cast

signal done

func start():
	if get_parent().get_child_count() >= get_parent().max_tile_count:
		queue_free()
		return
	forward_cast.force_raycast_update()
	left_cast.force_raycast_update()
	right_cast.force_raycast_update()
	back_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		create_tile(0)
	if not left_cast.is_colliding():
		create_tile(-PI/2)
	if not right_cast.is_colliding():
		create_tile(PI/2)
	if not back_cast.is_colliding():
		create_tile(PI)
	done.emit()

func create_tile(direction):
	var new_tile = self.duplicate()
	new_tile.global_position = global_position + Vector2(cos(rotation + direction), sin(rotation + direction)) * GlobalVariables.tile_size
	new_tile.rotation = rotation + direction
	new_tile.connect_to_prev(self)
	add_sibling(new_tile)
	await new_tile.done

func _on_previous_tile_done():
	start()

func connect_to_prev(tile):
	tile.done.connect(_on_previous_tile_done)
