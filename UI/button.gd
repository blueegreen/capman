extends Area2D

var level_manager
var pressed = false

func _ready():
	level_manager = get_parent().get_node_or_null("level_manager")
	if level_manager == null:
		queue_free()
		return

func _process(_delta):
	if pressed and (Input.is_action_just_released("left_click") or Input.is_action_just_released("right_click")):
		level_manager.state_transition(0)
		pressed = false

func _on_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_pressed("left_click"):
		if not pressed:
			level_manager.state_transition(2)
		pressed = true
	elif Input.is_action_pressed("right_click"):
		if not pressed:
			level_manager.state_transition(1)
		pressed = true
