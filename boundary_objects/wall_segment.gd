extends Node2D
@onready var static_wall = $StaticBody2D
@onready var mouse_detector = $Area2D
@onready var other_wall_detector = $RayCast2D

var mouse_position : Vector2
var rotate_allowed = true

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action("click") and not other_wall_detector.is_colliding() and rotate_allowed == true:
		var current_rotation = rotation
		var next_rotation = rotation + PI/2
		print(current_rotation)
		rotate_allowed = false
		var rotate_tween = create_tween()
		rotate_tween.tween_property(self, "rotation", next_rotation, 1).from(current_rotation).set_trans(Tween.TRANS_EXPO)
		rotate_tween.tween_callback(reset_permission)

func reset_permission():
	rotate_allowed = true
