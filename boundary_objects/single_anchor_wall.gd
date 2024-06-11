extends Node2D
@onready var anchor = $anchor
@onready var wall = $wall
@onready var point_1 = $wall/Area2D

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
var wiggle_time = 0.2

func _ready():
	GlobalTimer.timeout.connect(_on_beat)

func _process(delta):
	wiggle_time -= delta
	if wiggle_time > 0 and move_queued != null:
		rotate_around(move_queued)
		move_queued = null

func _on_beat():
	wiggle_time = 0.2
	if move_queued != null:
		rotate_around(move_queued)
		move_queued = null

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action("click") and rotate_allowed == true:
		move_queued = point_1

func complete_rotation():
	var wall_transform = wall.global_transform
	anchor.remove_child(wall)
	add_child(wall)
	anchor.rotation = 0
	wall.global_transform = wall_transform
	rotate_allowed = true
	changed.emit()
	
func rotate_around(point):
	rotate_allowed = false
	var wall_position = wall.global_position
	anchor.global_position = point.global_position
	remove_child(wall)
	anchor.add_child(wall)
	wall.global_position = wall_position
	
	var rotate_tween = create_tween()
	rotate_tween.tween_property(anchor, "rotation", rotation_angle, GlobalVariables.time_step - 0.1).set_trans(Tween.TRANS_EXPO)
	rotate_tween.tween_callback(complete_rotation)
