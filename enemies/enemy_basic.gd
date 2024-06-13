extends Area2D

@onready var forward_cast = $forward_cast

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
	end_pos = global_position + direction * GlobalVariables.tile_size
	end_pos = (end_pos * (2.0 / GlobalVariables.tile_size)).round() * GlobalVariables.tile_size / 2
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)

func move_back():
	if record_moves.size() > 0:
		var prev_move = record_moves.pop_back()
		var prev_pos = prev_move[0]
		var move_back_tween = create_tween()
		direction = prev_move[1]
		end_pos = prev_pos
		move_back_tween.tween_property(self, "global_position", prev_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)

func start_next_move():
	record_moves.push_back([end_pos, direction])
	find_next_direction()
	if direction != Vector2.ZERO:
		move()

func find_next_direction():
	var tile_count = get_overlapping_areas().size()
	if tile_count == 0:
		direction = Vector2.ZERO
		return false
	var tile = get_overlapping_areas()[tile_count - 1]
	if tile.is_in_group("tile"):
		var angle = tile.rotation + PI
		direction = Vector2(cos(angle), sin(angle)).normalized()
		return true
	else:
		direction = Vector2.ZERO
		return false
