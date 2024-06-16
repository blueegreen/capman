extends Node2D
const DIALOGUE_BOX = preload("res://UI/dialogue_box.tscn")
@export var level_start_delay := 2.5
@export var level_start_script : Script
@export var game_over_script : Script
@export var win_script : Script

var box

func _ready():
	box = DIALOGUE_BOX.instantiate()
	box.global_position = global_position
	add_child(box)

func level_start_dialogue():
	if level_start_script == null:
		return
	await get_tree().create_timer(level_start_delay).timeout
	box.display_array(level_start_script.lines)

func game_over_dialogue():
	var new_game_over_array : Array[String] = []
	new_game_over_array.push_back(game_over_script.lines[randi_range(0, 3)])
	new_game_over_array.push_back(game_over_script.lines[randi_range(4, 6)])
	box.display_array(new_game_over_array)

func win_dialogue():
	var new_win_array : Array[String] = []
	new_win_array.push_back(win_script.lines[randi_range(0, 3)])
	new_win_array.push_back(win_script.lines[randi_range(4, 5)])
	box.display_array(new_win_array)
