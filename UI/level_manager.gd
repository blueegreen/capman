extends Node2D
@onready var mouse_pointer = $mouse_pointer
@onready var rewind_sprite = $rewind_sprite
@onready var forward_sprite = $forward_sprite
@onready var score_label = $score_label
@onready var highscore_label = $highscore_label
@onready var theme_player = $theme_player
@onready var death_sfx = $death_sfx
@onready var win_sfx = $win_sfx

const WINDOW = preload("res://UI/pop_up_window.tscn")

@export var game_level = true
@export var level_timestep := 0.6
@export var next_level_path : String

var food_count := 0
var move_count := 0
var score := 0
var moving_entities = Array()
var moving_walls = Array()

var level_over = false
var pressed_left = false
var pressed_right = false
var pressed_time = 0.0

enum TIME_STATE {NORMAL, REWIND, FAST}
var current_time_state : TIME_STATE
var level_num : int
var dialogue_manager

func _ready():
	level_num = int(GameManager.current_scene.scene_file_path)
	dialogue_manager = get_parent().get_node_or_null("dialogue_manager")
	if dialogue_manager != null:
		dialogue_manager.level_start_dialogue()
	
	if game_level:
		highscore_label.text = "highscore: " + str(GlobalVariables.highscores[level_num])
	else:
		highscore_label.queue_free()
		score_label.queue_free()
	
	GlobalVariables.time_step = level_timestep
	GlobalVariables.levels[level_num] = true
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
	if not game_level:
		return
	match current_time_state:
		TIME_STATE.NORMAL:
			move_count += 1
			pass
		TIME_STATE.REWIND:
			move_count = max(0, move_count - 1)
		TIME_STATE.FAST:
			move_count += 1
			pass
	score_label.text = "moves: " + str(move_count)

func state_transition(new_state : TIME_STATE):
	match new_state:
		TIME_STATE.NORMAL:
			rewind_sprite.visible = false
			forward_sprite.visible = false
			theme_player.pitch_scale = 1
			
			for entity in moving_entities:
				entity.rewinding = false
			for moving_wall in moving_walls:
				moving_wall.rewinding = false
			GlobalVariables.time_step = level_timestep
		TIME_STATE.REWIND:
			forward_sprite.visible = false
			rewind_sprite.visible = true
			theme_player.pitch_scale = 1.25
			
			for entity in moving_entities:
				entity.rewinding = true
			for moving_wall in moving_walls:
				moving_wall.rewinding = true
			GlobalVariables.time_step = 0.3
		TIME_STATE.FAST:
			forward_sprite.visible = true
			rewind_sprite.visible = false
			theme_player.pitch_scale = 1.25
			
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
	if level_over:
		return
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
	level_over = true
	death_sfx.play()
	theme_player.pitch_scale = 0.9
	if dialogue_manager != null:
		dialogue_manager.game_over_dialogue()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.visible = false
	GlobalTimer.stop()
	var new_window = WINDOW.instantiate()
	new_window.global_position = global_position
	new_window.mode = 0
	new_window.level_manager = self
	call_deferred("add_child", new_window)

func finish_level():
	level_over = true
	win_sfx.play()
	if dialogue_manager != null:
		dialogue_manager.level_end_dialogue()
	if GlobalVariables.highscores[level_num] > move_count:
		GlobalVariables.highscores[level_num] = move_count
		highscore_label.text = "highscore: " + str(move_count)
	GlobalTimer.stop()
	
	if not next_level_path.is_empty():
		GlobalVariables.levels[level_num+1] = true
	
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
