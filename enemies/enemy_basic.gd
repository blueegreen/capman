extends Area2D

@onready var forward_cast = $forward_cast

var direction := Vector2.ZERO

func _ready():
	forward_cast.target_position = Vector2(GlobalVariables.tile_size, 0)
	GlobalTimer.timeout.connect(_on_beat)

func _on_beat():
	start_next_move()

func move():	
	var end_pos = global_position + direction * GlobalVariables.tile_size
	end_pos = (end_pos * (2.0 / GlobalVariables.tile_size)).round() * GlobalVariables.tile_size / 2
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)

func start_next_move():
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
