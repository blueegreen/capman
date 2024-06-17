extends Area2D

@export var level_num := 1
var level_manager
var level_unlocked = false
@onready var sprite = $panel/Sprite2D
@onready var text = $panel/Label
@onready var panel = $panel

func _ready():
	level_manager = get_parent().get_node_or_null("level_manager")
	text.text = str(level_num)
	set_sprite()

func set_sprite():
	if GlobalVariables.levels[level_num] == true:
		sprite.frame = 0
		level_unlocked = true
	else:
		sprite.frame = 1

func _on_input_event(_viewport, _event, _shape_idx):
	if level_unlocked:
		panel.position = Vector2.UP * 15
	else:
		panel.position = Vector2.UP * 10
	if level_manager == null:
		return
	if Input.is_action_just_pressed("left_click") and level_unlocked:
		level_manager.next_level_path = "res://levels/lvl_" + str(level_num) + ".tscn"
		level_manager.go_to_next_level()

func _on_mouse_exited():
	panel.position = Vector2.ZERO


func _on_mouse_entered():
	GlobalAudioManager.pop_sound()
