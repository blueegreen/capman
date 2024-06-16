extends Node2D

var player
var radius := 96
@onready var sprite = $Sprite2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.new_dir.connect(_on_new_dir_chosen)

func _on_new_dir_chosen(new_dir):
	var end_pos = new_dir * radius
	var move_tween = create_tween()
	move_tween.tween_property(sprite, "position", end_pos, GlobalVariables.time_step).set_trans(Tween.TRANS_EXPO)
