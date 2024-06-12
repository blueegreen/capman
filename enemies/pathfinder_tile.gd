extends Area2D

@onready var forward_cast = $forward_cast

signal done

func _ready():
	forward_cast.target_position = Vector2(GlobalVariables.tile_size, 0)
	start()

func start():
	await get_tree().create_timer(0.005).timeout
	if get_parent().get_child_count() >= get_parent().max_tile_count:
		queue_free()
		return
	move_in_all_dir()

func move_in_all_dir():
	for i in range(4):
		forward_cast.force_raycast_update()
		if not forward_cast.is_colliding():
			var new_tile = self.duplicate()
			new_tile.global_position = global_position + Vector2(cos(rotation), sin(rotation)) * GlobalVariables.tile_size
			new_tile.rotation = rotation
			add_sibling(new_tile)
		rotation += PI/2
