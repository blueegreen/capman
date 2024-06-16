extends Node2D
const DIALOGUE_BOX = preload("res://UI/dialogue_box.tscn")
@export var level_start_delay := 2.5
@export var level_start_script : Script
@export var level_end_script : Script
@export var game_over_script : Script
@export var win_script : Script

var box

func _ready():
	global_position = Vector2(randf_range(1400, 1600), randf_range(-128, -256))
	make_new_box()

func level_start_dialogue():
	if level_start_script == null:
		return
	await get_tree().create_timer(level_start_delay).timeout
	make_new_box()
	box.display_array(level_start_script.lines)

func level_end_dialogue():
	if level_end_script == null:
		win_dialogue()
		return
	make_new_box()
	box.display_array(level_end_script.lines)

func game_over_dialogue():
	if game_over_script == null:
		return
	make_new_box()
	var new_game_over_array : Array[String] = []
	new_game_over_array.push_back(game_over_script.lines[randi_range(0, 3)])
	new_game_over_array.push_back(game_over_script.lines[randi_range(4, 6)])
	box.display_array(new_game_over_array)

func win_dialogue():
	if win_script == null:
		return
	var new_win_array : Array[String] = []
	new_win_array.push_back(win_script.lines[randi_range(0, 3)])
	new_win_array.push_back(win_script.lines[randi_range(4, 5)])
	box.display_array(new_win_array)

func make_new_box():
	if box:
		box.free()
	box = DIALOGUE_BOX.instantiate()
	box.global_position = global_position
	add_child(box)
