extends Area2D
@onready var player = $"."



func _on_area_exited():
	queue_free()
