extends Area2D

@onready var forward_cast = $forward_cast
@onready var enemy_sprite = $enemy_sprite

var direction := Vector2.ZERO
var end_pos : Vector2
var new_end_pos : Vector2

var record_moves = Array()
var rewinding = false

func _ready():
	forward_cast.target_position = Vector2(20 * GlobalVariables.tile_size, 0)
	GlobalTimer.timeout.connect(_on_beat)
	end_pos = global_position

func _on_beat():
	if rewinding:
		move_back()
	else:
		start_next_move()

func move():	
	end_pos = new_end_pos
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
	move_tween.parallel().tween_property(enemy_sprite, "frame", (enemy_sprite.frame + 1) % 2, GlobalVariables.time_step)

func move_back():
	if record_moves.size() > 0:
		var prev_move = record_moves.pop_back()
		var prev_pos = prev_move[0]
		var move_back_tween = create_tween()
		direction = prev_move[1]
		end_pos = prev_pos
		move_back_tween.tween_property(self, "global_position", prev_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
		move_back_tween.parallel().tween_property(enemy_sprite, "frame", (enemy_sprite.frame + 1) % 2, GlobalVariables.time_step)
		
func start_next_move():
	record_moves.push_back([end_pos, direction])
	find_next_direction()
	find_end_pos()
	move()

func find_next_direction():
	var left_open = false
	var right_open = false
	var forward_rotation = atan2(direction.y, direction.x)
	forward_cast.rotation  = forward_rotation
	
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
		new_end_pos = global_position + direction * GlobalVariables.tile_size
	else:
		direction = direction.normalized()
		new_end_pos = global_position + floor(forward_cast.get_collider().global_position.distance_to(global_position) / GlobalVariables.tile_size) * GlobalVariables.tile_size * direction
		new_end_pos = (new_end_pos * (2.0 / GlobalVariables.tile_size)).round() * GlobalVariables.tile_size / 2
