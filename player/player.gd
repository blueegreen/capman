extends Area2D

@onready var forward_cast = $forward_cast
@onready var player_sprite = $player_sprite
@onready var player_sprite_dead = $player_sprite_dead
signal game_over

var direction := Vector2.ZERO
var end_pos : Vector2

var record_moves = Array()
var rewinding = false

func _ready():
	forward_cast.target_position = Vector2(GlobalVariables.tile_size, 0)
	GlobalTimer.timeout.connect(_on_beat)
	end_pos = global_position

func _on_beat():
	if rewinding:
		move_back()
	else:
		start_next_move()

func move():	
	forward_cast.rotation = atan2(direction.y, direction.x)
	player_sprite.rotation = forward_cast.rotation
	if player_sprite.rotation > PI/2 + 0.1 or player_sprite.rotation < -PI/2 - 0.1:
		player_sprite.flip_v = true
	else:
		player_sprite.flip_v = false
	end_pos = global_position + direction * GlobalVariables.tile_size
	end_pos = (end_pos * (2.0 / GlobalVariables.tile_size)).round() * GlobalVariables.tile_size / 2
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
	move_tween.parallel().tween_property(player_sprite, "frame", (player_sprite.frame + 1) % 2, GlobalVariables.time_step)
	
func move_back():
	if record_moves.size() > 0:
		var prev_move = record_moves.pop_back()
		var prev_pos = prev_move[0]
		var move_back_tween = create_tween()
		end_pos = prev_pos
		direction = prev_move[1]
		
		player_sprite.rotation = prev_pos.direction_to(global_position).angle()
		if player_sprite.rotation > PI/2 + 0.1 or player_sprite.rotation < -PI/2 - 0.1:
			player_sprite.flip_v = true
		else:
			player_sprite.flip_v = false
		
		move_back_tween.tween_property(self, "global_position", prev_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
		move_back_tween.parallel().tween_property(player_sprite, "frame", (player_sprite.frame + 1) % 2, GlobalVariables.time_step)
		
func start_next_move():
	record_moves.push_back([end_pos, direction])
	find_next_direction()
	if direction != Vector2.ZERO:
		move()

func find_next_direction():
	var left_open = 0
	var right_open = 0
	var forward_rotation = atan2(direction.y, direction.x)
	forward_cast.rotation  = forward_rotation
	
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		direction = Vector2(cos(forward_rotation), sin(forward_rotation))
		return
	if forward_cast.is_colliding():
		if forward_cast.get_collider().is_in_group("collectible"):
			direction = Vector2(cos(forward_rotation), sin(forward_rotation))
			return
		
	forward_cast.rotation += PI/2
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		right_open = 1
	if forward_cast.is_colliding():
		if forward_cast.get_collider().is_in_group("collectible"):
			right_open = 2
	
	forward_cast.rotation -= PI
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		left_open = 1
	if forward_cast.is_colliding():
		if forward_cast.get_collider().is_in_group("collectible"):
			left_open = 2
	
	if left_open > 0 and right_open > 0:
		if left_open == right_open:
			if randi_range(0, 1) == 0:
				direction = Vector2(cos(forward_rotation - PI/2), sin(forward_rotation - PI/2))
			else:
				direction = Vector2(cos(forward_rotation + PI/2), sin(forward_rotation + PI/2))
			return
	if left_open > right_open:
		direction = Vector2(cos(forward_rotation - PI/2), sin(forward_rotation - PI/2))
		return
	elif right_open > left_open:
		direction = Vector2(cos(forward_rotation + PI/2), sin(forward_rotation + PI/2))
		return
	
	forward_cast.rotation -= PI/2
	forward_cast.force_raycast_update()
	if not forward_cast.is_colliding():
		direction = Vector2(cos(forward_rotation + PI), sin(forward_rotation + PI))
		return
	if forward_cast.is_colliding():
		if forward_cast.get_collider().is_in_group("collectible"):
			direction = Vector2(cos(forward_rotation + PI), sin(forward_rotation + PI))
			return
	
	direction = Vector2.ZERO
	return

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		player_sprite.visible = false
		player_sprite_dead.visible = true
		player_sprite_dead.rotation = player_sprite.rotation
		player_sprite_dead.flip_v = player_sprite.flip_v
		game_over.emit()
	elif area.is_in_group("collectible"):
		area.collect()
