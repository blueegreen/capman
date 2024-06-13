extends Area2D
@onready var anchor = $anchor
@onready var wall = $wall
@onready var point_1 = $Area2D
@onready var point_2 = $Area2D2
var root

enum DIR {CW, ACW}
signal changed

var mouse_position : Vector2
var rotate_allowed = true
@export var rotation_dir = DIR.CW:
	set(value):
		if value == DIR.CW:
			rotation_angle = abs(rotation_angle)
		elif value == DIR.ACW:
			rotation_angle = -abs(rotation_angle)
		rotation_dir = value
@export var rotation_angle = PI/2

var move_queued = null

func _ready():
	root = get_parent()
	GlobalTimer.timeout.connect(_on_beat)

func _on_beat():
	if move_queued != null and rotate_allowed:
		rotate_around(move_queued)
		move_queued = null

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if point_1.get_overlapping_areas().size() > 0:
		for obj in point_1.get_overlapping_areas():
			if obj.is_in_group("fixed_wall"):
				return
	if Input.is_action_just_pressed("left_click"):
		rotation_dir = DIR.CW
		move_queued = point_1
	if Input.is_action_just_pressed("right_click"):
		rotation_dir = DIR.ACW
		move_queued = point_1

func complete_rotation():
	var wall_transform = wall.global_transform
	anchor.remove_child(wall)
	add_child(wall)
	anchor.rotation = 0
	wall.global_transform = wall_transform
	rotate_allowed = true

func _on_area_2d_2_input_event(_viewport, _event, _shape_idx):
	if point_2.get_overlapping_areas().size() > 0:
		for obj in point_2.get_overlapping_areas():
			if obj.is_in_group("fixed_wall"):
				return
	if Input.is_action_just_pressed("left_click"):
		rotation_dir = DIR.CW
		move_queued = point_2
	if Input.is_action_just_pressed("right_click"):
		rotation_dir = DIR.ACW
		move_queued = point_2

func rotate_around(point):
	rotate_allowed = false
	rotate_area(point)
	var wall_position = wall.global_position
	anchor.global_position = point.global_position
	remove_child(wall)
	anchor.add_child(wall)
	wall.global_position = wall_position
	
	var rotate_tween = create_tween()
	rotate_tween.tween_property(anchor, "rotation", rotation_angle, GlobalVariables.time_step - 0.1).set_trans(Tween.TRANS_EXPO)
	rotate_tween.tween_callback(complete_rotation)

func rotate_area(point):
	var wall_transform = wall.global_transform
	var r = global_position.distance_to(point.global_position)
	var dir = point.global_position.direction_to(global_position)
	var theta = atan2(dir.y, dir.x)
	global_position = r * Vector2(cos(theta + rotation_angle), sin(theta + rotation_angle)) + point.global_position
	rotation += rotation_angle
	wall.global_transform = wall_transform
