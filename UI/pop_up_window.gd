extends Node2D

enum MODE {GAME_OVER, WIN}

var mouse_pressed = false
var mouse_offset : Vector2
var level_manager : Node2D
@export var mode := MODE.GAME_OVER

@onready var game_over_window = $game_over_window
@onready var win_window = $win_window
@onready var win_reload_sprite = $win_window/win_reload_sprite
@onready var game_over_reload = $game_over_window/game_over_reload
@onready var game_over_reload_sprite = $game_over_window/game_over_reload_sprite
@onready var win_continue_sprite = $win_window/win_continue_sprite
@onready var win_reload = $win_window/win_reload
@onready var win_continue = $win_window/win_continue

func _ready():
	match mode:
		MODE.GAME_OVER:
			game_over_window.visible = true
			game_over_reload.set_collision_layer_value(1, true)
		MODE.WIN:
			win_window.visible = true
			win_reload.set_collision_layer_value(1, true)
			win_continue.set_collision_layer_value(1, true)


func _process(delta):
	if mouse_pressed:
		if Input.is_action_just_released("left_click"):
			mouse_pressed = false
			return
		global_position = global_position.lerp(get_global_mouse_position() - mouse_offset, 10 * delta)

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_pressed("left_click"):
		if not mouse_pressed:
			mouse_pressed = true
			mouse_offset = get_global_mouse_position() - global_position


func _on_game_over_reload_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.reload_level()


func _on_win_reload_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.reload_level()


func _on_win_continue_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.go_to_next_level()
