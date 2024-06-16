extends Area2D
signal collected
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func collect():
	collected.emit()
	set_collision_layer_value(4, false)
	audio_stream_player_2d.play()
	await get_tree().create_timer(GlobalVariables.time_step / 2.0).timeout
	queue_free()
