extends Area2D

func collect():
	set_collision_layer_value(4, false)
	await get_tree().create_timer(GlobalVariables.time_step / 2.0).timeout
	queue_free()
