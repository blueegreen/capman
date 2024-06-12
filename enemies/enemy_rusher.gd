extends Area2D

@onready var forward_cast = $forward_cast

var direction := Vector2.ZERO
var end_pos := Vector2.ZERO

func _ready():
	forward_cast.target_position = Vector2(20 * GlobalVariables.tile_size, 0)
	GlobalTimer.timeout.connect(_on_beat)

func _on_beat():
	start_next_move()

func move():	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)

func start_next_move():
	find_next_direction()
	if direction != Vector2.ZERO:
		find_end_pos()
		move()

func find_next_direction():
	var left_open = false
	var right_open = false
	var forward_rotation = forward_cast.rotation
	
	forward_cast.force_raycast_update()
	if forward_cast.is_colliding():
		if forward_cast.get_collider().global_position.distance_to(global_position) > GlobalVariables.tile_size:
			direction = Vector2(cos(forward_rotation), sin(forward_rotation))
			return
		
	forward_cast.rotation += PI/2
	forward_cast.force_raycast_update()
	if forward_cast.is_colliding():
		if forward_cast.get_collider().global_position.distance_to(global_position) > GlobalVariables.tile_size:
			right_open = true
	
	forward_cast.rotation -= PI
	forward_cast.force_raycast_update()
	if forward_cast.is_colliding():
		if forward_cast.get_collider().global_position.distance_to(global_position) > GlobalVariables.tile_size:
			left_open = true
	
	if left_open and right_open:
		if randi_range(0, 1) == 0:
			direction = Vector2(cos(forward_rotation - PI/2), sin(forward_rotation - PI/2))
		else:
			direction = Vector2(cos(forward_rotation + PI/2), sin(forward_rotation + PI/2))
		return
	elif left_open:
		direction = Vector2(cos(forward_rotation - PI/2), sin(forward_rotation - PI/2))
		return
	elif right_open:
		direction = Vector2(cos(forward_rotation + PI/2), sin(forward_rotation + PI/2))
		return
	
	forward_cast.rotation -= PI/2
	forward_cast.force_raycast_update()
	if forward_cast.is_colliding():
		if forward_cast.get_collider().global_position.distance_to(global_position) > GlobalVariables.tile_size:
			direction = Vector2(cos(forward_rotation + PI), sin(forward_rotation + PI))
			return
	direction = Vector2.ZERO

func find_end_pos():
	forward_cast.rotation = atan2(direction.y, direction.x)
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		end_pos = global_position + direction * GlobalVariables.tile_size
	else:
		direction = direction.normalized()
		end_pos = global_position + floor(forward_cast.get_collider().global_position.distance_to(global_position) / GlobalVariables.tile_size) * GlobalVariables.tile_size * direction
