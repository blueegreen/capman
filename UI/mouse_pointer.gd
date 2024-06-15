extends Node2D

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _process(_delta):
	global_position = get_global_mouse_position()
