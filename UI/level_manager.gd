extends Node

@export var level_timestep := 1.0

var food_count := 0
var score := 0
var moving_entities = Array()
var moving_walls = Array()

enum TIME_STATE {NORMAL, REWIND, FAST}
var current_time_state : TIME_STATE

func _ready():
	GlobalVariables.time_step = level_timestep
	current_time_state = TIME_STATE.NORMAL
	for collectible in get_tree().get_nodes_in_group("collectible"):
		collectible.collected.connect(_on_collectible_collected)
		food_count += 1
	moving_entities = get_tree().get_nodes_in_group("moving_entity")
	moving_walls = get_tree().get_nodes_in_group("movable_wall")
	
	GlobalTimer.timeout.connect(_on_beat)

func _on_beat():
	match current_time_state:
		TIME_STATE.NORMAL:
			pass
		TIME_STATE.REWIND:
			pass
		TIME_STATE.FAST:
			pass

func state_transition(new_state : TIME_STATE):
	match new_state:
		TIME_STATE.NORMAL:
			for entity in moving_entities:
				entity.rewinding = false
			for moving_wall in moving_walls:
				moving_wall.rewinding = false
			GlobalVariables.time_step = level_timestep
		TIME_STATE.REWIND:
			for entity in moving_entities:
				entity.rewinding = true
			for moving_wall in moving_walls:
				moving_wall.rewinding = true
			GlobalVariables.time_step = 0.8
		TIME_STATE.FAST:
			GlobalVariables.time_step = 0.4

func _on_collectible_collected(_msg = {}):
	score +=1
	if score >= food_count:
		print("level_complete")
		await get_tree().create_timer(GlobalVariables.time_step / 2.0).timeout
		get_tree().reload_current_scene()
