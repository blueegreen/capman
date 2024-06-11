extends Node2D
@onready var anchor = $anchor
@onready var wall = $wall
@onready var point_1 = $wall/Area2D
@onready var point_2 = $wall/Area2D2

enum DIR {CW, ACW}

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

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action("click") and rotate_allowed == true:
		rotate_around(point_1)

func complete_rotation():
	var wall_transform = wall.global_transform
	anchor.remove_child(wall)
	add_child(wall)
	anchor.rotation = 0
	wall.global_transform = wall_transform
	rotate_allowed = true
	
func _on_area_2d_2_input_event(_viewport, event, _shape_idx):
	if event.is_action("click") and rotate_allowed == true:
		rotate_around(point_2)

func rotate_around(point):
	rotate_allowed = false
	var wall_position = wall.global_position
	anchor.global_position = point.global_position
	remove_child(wall)
	anchor.add_child(wall)
	wall.global_position = wall_position
	
	var rotate_tween = create_tween()
	rotate_tween.tween_property(anchor, "rotation", rotation_angle, 0.5).set_trans(Tween.TRANS_EXPO)
	rotate_tween.tween_callback(complete_rotation)
