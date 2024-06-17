extends Node
@onready var click = $click
@onready var pop = $pop

func _process(_delta):
	if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
		click.play()

func pop_sound():
	pop.pitch_scale = randf_range(0.6, 0.8)
	pop.play()
