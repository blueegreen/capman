extends Node2D
@onready var mouse_pointer = $mouse_pointer
const WINDOW = preload("res://UI/pop_up_window.tscn")

@export var level_timestep := 0.6
@export var next_level_path : String

var food_count := 0
var score := 0
var moving_entities = Array()
var moving_walls = Array()

var pressed_left = false
var pressed_right = false
var pressed_time = 0.0

enum TIME_STATE {NORMAL, REWIND, FAST}
var current_time_state : TIME_STATE

func _ready():
	GlobalVariables.time_step = level_timestep
	GlobalTimer.start()
	current_time_state = TIME_STATE.NORMAL
	for collectible in get_tree().get_nodes_in_group("collectible"):
		collectible.collected.connect(_on_collectible_collected)
		food_count += 1
	for player in get_tree().get_nodes_in_group("player"):
		player.game_over.connect(_on_game_over)
	moving_entities = get_tree().get_nodes_in_group("moving_entity")
	moving_walls = get_tree().get_nodes_in_group("movable_wall")
	
	GlobalTimer.timeout.connect(_on_beat)

func _process(delta):
	handle_input(delta)

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
			GlobalVariables.time_step = 0.3
		TIME_STATE.FAST:
			for entity in moving_entities:
				entity.rewinding = false
			for moving_wall in moving_walls:
				moving_wall.rewinding = false
			GlobalVariables.time_step = 0.3
		
	current_time_state = new_state

func _on_collectible_collected(_msg = {}):
	score +=1
	if score >= food_count:
		finish_level()

func handle_input(delta):
	if Input.is_action_pressed("left_click"):
		if not pressed_left:
			pressed_left = true
			pressed_right = false
			pressed_time = 0
		else:
			mouse_pointer.get_node("Sprite2D").frame = 2 
			pressed_time += delta
			if pressed_time > 0.2 and current_time_state != TIME_STATE.FAST:
				state_transition(TIME_STATE.FAST)
	elif Input.is_action_pressed("right_click"):
		if not pressed_right:
			pressed_right = true
			pressed_left = false
			pressed_time = 0
		else:
			mouse_pointer.get_node("Sprite2D").frame = 1
			pressed_time += delta
			if pressed_time > 0.2 and current_time_state != TIME_STATE.REWIND:
				state_transition(TIME_STATE.REWIND)
	else:
		mouse_pointer.get_node("Sprite2D").frame = 0
		pressed_time = 0.0
		pressed_left = false
		pressed_right = false
		if current_time_state != TIME_STATE.NORMAL:
			state_transition(TIME_STATE.NORMAL)

func _on_game_over():
	print("game_over")
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.visible = false
	GlobalTimer.stop()
	var new_window = WINDOW.instantiate()
	new_window.global_position = global_position
	new_window.mode = 0
	new_window.level_manager = self
	call_deferred("add_child", new_window)

func finish_level():
	print("finish_level")
	GlobalTimer.stop()
	var new_window = WINDOW.instantiate()
	new_window.global_position = global_position
	new_window.mode = 1
	new_window.level_manager = self
	call_deferred("add_child", new_window)

func reload_level():
	GameManager.goto_scene(get_tree().current_scene.scene_file_path)

func go_to_next_level():
	if not next_level_path.is_empty():
		GameManager.goto_scene(next_level_path)
