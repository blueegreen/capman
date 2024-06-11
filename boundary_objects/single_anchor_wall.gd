extends Node2D
@onready var anchor = $anchor
@onready var wall = $wall
@onready var point_1 = $wall/Area2D


var mouse_position : Vector2
var rotate_allowed = true

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action("click") and rotate_allowed == true:
		rotate_around(point_1)

func complete_rotation():
	var wall_position = wall.global_position
	var wall_rotation = wall.global_rotation
	anchor.remove_child(wall)
	add_child(wall)
	anchor.rotation = 0
	wall.global_position = wall_position
	wall.global_rotation = wall_rotation
	rotate_allowed = true
	
func rotate_around(point):
	rotate_allowed = false
	var wall_position = wall.global_position
	anchor.global_position = point.global_position
	remove_child(wall)
	anchor.add_child(wall)
	wall.global_position = wall_position
	
	var rotate_tween = create_tween()
	rotate_tween.tween_property(anchor, "rotation", PI/2, 0.5).set_trans(Tween.TRANS_EXPO)
	rotate_tween.tween_callback(complete_rotation)
