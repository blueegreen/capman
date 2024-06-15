extends Node2D

@onready var sprite = $Sprite2D
var mouse_offset : Vector2
var init_pos : Vector2

func _process(_delta):
	mouse_offset = get_global_mouse_position() - Vector2.ZERO
	sprite.position = mouse_offset / 5
	sprite.position.limit_length(40)
