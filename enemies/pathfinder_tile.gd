extends Area2D

@onready var forward_cast = $forward_cast

var gen := 0

func _ready():
	global_position = (global_position * (2.0 / GlobalVariables.tile_size)).round() * GlobalVariables.tile_size / 2
	forward_cast.target_position = Vector2(GlobalVariables.tile_size, 0)
	start()

func start():
	if get_parent().get_child_count() >= get_parent().max_tile_count:
		queue_free()
		return
	move_in_all_dir()

func move_in_all_dir():
	for i in range(4):
		forward_cast.force_raycast_update()
		if forward_cast.is_colliding():
			var object = forward_cast.get_collider()
			if object.is_in_group("tile"):
				if gen < object.gen:
					object.free()
					forward_cast.force_raycast_update()
		if not forward_cast.is_colliding():
			var new_tile = self.duplicate()
			new_tile.global_position = global_position + Vector2(cos(rotation), sin(rotation)) * GlobalVariables.tile_size
			new_tile.rotation = rotation
			new_tile.gen = gen + 1
			add_sibling(new_tile)
		rotation += PI/2
