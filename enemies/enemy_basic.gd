extends Area2D

@onready var forward_cast = $forward_cast
@onready var left_cast = $left_cast
@onready var right_cast = $right_cast
@onready var back_cast = $back_cast

var speed := 150.0
var direction := Vector2.RIGHT
var next_direction : Vector2
var tile_size = 128

var stopped = false

func _process(_delta):
	if next_direction == Vector2.ZERO:
		if find_next_direction():
			start_next_move()

func move():	
	var end_pos = global_position + direction * tile_size
	var move_tween = create_tween()
	move_tween.tween_property(self, "global_position", end_pos, tile_size / speed).set_trans(Tween.TRANS_EXPO)
	move_tween.tween_callback(start_next_move)

func start_next_move():
	find_next_direction()
	if next_direction != Vector2.ZERO:
		direction = next_direction
		move()
	pass

func find_next_direction():
	var tile_count = get_overlapping_areas().size()
	if tile_count == 0:
		next_direction = Vector2.ZERO
		return false
	var tile = get_overlapping_areas()[tile_count - 1]
	if tile.is_in_group("tile"):
		var angle = tile.rotation + PI
		next_direction = Vector2(cos(angle), sin(angle)).normalized()
		return true
	else:
		next_direction = Vector2.ZERO
		return false
