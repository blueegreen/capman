extends Node2D
@onready var mouse_pointer = $mouse_pointer
@onready var rewind_sprite = $rewind_sprite
@onready var forward_sprite = $forward_sprite
@onready var score_label = $score_label
@onready var highscore_label = $highscore_label
@onready var theme_player = $theme_player
@onready var theme_rewind_player = $theme_rewind_player
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
	tutorial()
	dialogue_manager = get_parent().get_node_or_null("dialogue_manager")
	if dialogue_manager != null:
		dialogue_manager.level_start_dialogue()
	
	if game_level:
		$theme_player.play()
		if GlobalVariables.highscores[level_num] < 1000:
			highscore_label.text = "highscore: " + str(GlobalVariables.highscores[level_num])
		else:
			highscore_label.text = "highscore: "
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
	if Input.is_action_just_pressed("reload") and game_level:
		reload_level()

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
	await get_tree().create_timer(GlobalVariables.time_step / 2.0).timeout
	score_label.text = "time: " + str(move_count)

func state_transition(new_state : TIME_STATE):
	var stream_pos 
	match new_state:
		TIME_STATE.NORMAL:
			rewind_sprite.visible = false
			forward_sprite.visible = false
			theme_player.pitch_scale = 1
			
			if theme_rewind_player.playing:
				stream_pos = theme_rewind_player.get_playback_position()
				theme_rewind_player.stop()
				theme_player.play(9.64 - stream_pos)
			
			for entity in moving_entities:
				entity.rewinding = false
			for moving_wall in moving_walls:
				moving_wall.rewinding = false
			GlobalVariables.time_step = level_timestep
			
		TIME_STATE.REWIND:
			forward_sprite.visible = false
			rewind_sprite.visible = true
			
			stream_pos = theme_player.get_playback_position()
			theme_player.stop()
			theme_rewind_player.play(9.64 - stream_pos)
			
			for entity in moving_entities:
				entity.rewinding = true
			for moving_wall in moving_walls:
				moving_wall.rewinding = true
			GlobalVariables.time_step = 0.3
			
		TIME_STATE.FAST:
			forward_sprite.visible = true
			rewind_sprite.visible = false
			theme_player.pitch_scale = 1.25
			
			if theme_rewind_player.playing:
				stream_pos = theme_rewind_player.get_playback_position()
				theme_rewind_player.stop()
				theme_player.play(9.64 - stream_pos)
			
			for entity in moving_entities:
				entity.rewinding = false
			for moving_wall in moving_walls:
				moving_wall.rewinding = false
			GlobalVariables.time_step = 0.3
		
	current_time_state = new_state

func _on_collectible_collected(_msg = {}):
	score += 1
	if score >= food_count:
		finish_level()

func handle_input(delta):
	if level_num < 3:
		return
	if Input.is_action_pressed("left_click") and not level_over:
		if not pressed_left:
			pressed_left = true
			pressed_right = false
			pressed_time = 0
		else:
			mouse_pointer.get_node("Sprite2D").frame = 2 
			pressed_time += delta
			if pressed_time > 0.2 and current_time_state != TIME_STATE.FAST:
				state_transition(TIME_STATE.FAST)
	elif Input.is_action_pressed("right_click") and not level_over:
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
	new_window.global_position = Vector2(randf_range(-192, 192), randf_range(-192, 192))
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
	GameManager.save_game()
	GlobalTimer.stop()
	
	if not next_level_path.is_empty():
		GlobalVariables.levels[level_num+1] = true
	
	var new_window = WINDOW.instantiate()
	new_window.global_position = Vector2(randf_range(-320, 320), randf_range(-320, 320))
	new_window.mode = 1
	new_window.level_manager = self
	call_deferred("add_child", new_window)

func reload_level():
	GameManager.goto_scene(get_tree().current_scene.scene_file_path)

func go_to_next_level():
	if not next_level_path.is_empty():
		GameManager.goto_scene(next_level_path)

func tutorial():
	if level_num > 3 or level_num < 1:
		return
	var new_window = WINDOW.instantiate()
	new_window.global_position = global_position
	new_window.mode = 2
	match level_num:
		1:
			new_window.global_position = Vector2(192, -192)
			new_window.tut_text = "click on wall anchors to rotate them"
			new_window.tut_delay = 6.5
		2:
			new_window.global_position = Vector2(-320, -256)
			new_window.tut_text = "left click for clockwise\nright click for anticlockwise"
			new_window.tut_delay = 1
		3:
			new_window.global_position = Vector2(320, -320)
			new_window.tut_text = "hold left click to speed up\nhold right click to rewind"
			new_window.tut_delay = 1
	new_window.level_manager = self
	call_deferred("add_child", new_window)
