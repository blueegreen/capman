extends Area2D

@onready var forward_cast = $forward_cast
var direction := Vector2.ZERO
var end_pos : Vector2

func _ready():
	forward_cast.target_position = Vector2(GlobalVariables.tile_size, 0)
	GlobalTimer.timeout.connect(_on_beat)
	end_pos = global_position

func _on_beat():
	start_next_move()

func move():	
	forward_cast.rotation = atan2(direction.y, direction.x)
	end_pos = global_position + direction * GlobalVariables.tile_size
	$test.global_position = end_pos
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)

func start_next_move():
	find_next_direction()
	if direction != Vector2.ZERO:
		move()

func find_next_direction():
	var left_open = false
	var right_open = false
	var forward_rotation = forward_cast.rotation
	
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		direction = Vector2(cos(forward_rotation), sin(forward_rotation))
		return
		
	forward_cast.rotation += PI/2
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		right_open = true
	
	forward_cast.rotation -= PI
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
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
	if not forward_cast.is_colliding():
		direction = Vector2(cos(forward_rotation + PI), sin(forward_rotation + PI))
		return
	direction = Vector2.ZERO
	return
