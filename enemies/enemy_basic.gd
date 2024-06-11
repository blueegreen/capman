extends Area2D

@onready var forward_cast = $forward_cast
@onready var left_cast = $left_cast
@onready var right_cast = $right_cast
@onready var back_cast = $back_cast

var direction := Vector2.ZERO
var next_direction : Vector2
var tile_size = 128

var paused = false

func _process(_delta):
	if paused:
		return
	if direction == Vector2.ZERO:
		start_next_move()

func move():	
	var end_pos = global_position + direction * tile_size
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
	move_tween.tween_callback(start_next_move)

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

func pause():
	paused = true
	await get_tree().create_timer(GlobalVariables.time_step).timeout
	paused = false
