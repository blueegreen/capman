extends Area2D

@onready var forward_cast = $forward_cast
@onready var left_cast = $left_cast
@onready var right_cast = $right_cast
@onready var back_cast = $back_cast

var direction := Vector2.ZERO

func _ready():
	GlobalTimer.timeout.connect(_on_beat)

func _on_beat():
	start_next_move()

func move():	
	var end_pos = global_position + direction * GlobalVariables.tile_size
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
