extends Area2D

@onready var forward_cast = $forward_cast

signal done

func _ready():
	start()

func start():
	if get_parent().get_child_count() >= get_parent().max_tile_count:
		queue_free()
		return
	move_in_all_dir()

func move_in_all_dir():
	for i in range(4):
		forward_cast.force_raycast_update()
		position += Vector2(cos(rotation), sin(rotation)) * GlobalVariables.tile_size
		if not forward_cast.is_colliding():
			var new_tile = self.duplicate()
			new_tile.global_position = global_position
			new_tile.rotation = rotation
			add_sibling(new_tile)
		position -= Vector2(cos(rotation), sin(rotation)) * GlobalVariables.tile_size
		rotation += PI/2
