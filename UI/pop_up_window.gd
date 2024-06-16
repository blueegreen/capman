extends Node2D

enum MODE {GAME_OVER, WIN}

var mouse_pressed = false
var mouse_offset : Vector2
var level_manager : Node2D
@export var mode := MODE.GAME_OVER

@onready var exit_icon = $exit/exit_icon
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
		global_position = global_position.lerp(get_global_mouse_position() - mouse_offset, 20 * delta)
		global_position.x = clampf(global_position.x, -576, 512)
		global_position.y = clampf(global_position.y, -576, 512)

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_pressed("left_click"):
		if not mouse_pressed:
			mouse_pressed = true
			mouse_offset = get_global_mouse_position() - global_position


func _on_game_over_reload_input_event(_viewport, _event, _shape_idx):
	game_over_reload_sprite.scale = Vector2(1, 1) * 1.1
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.reload_level()


func _on_win_reload_input_event(_viewport, _event, _shape_idx):
	win_reload_sprite.scale = Vector2(1, 1) * 1.1
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.reload_level()


func _on_win_continue_input_event(_viewport, _event, _shape_idx):
	win_continue_sprite.scale = Vector2(1, 1) * 1.1
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.go_to_next_level()

func _on_exit_input_event(_viewport, _event, _shape_idx):
	exit_icon.scale = Vector2(1, 1) * (1.1)
	if Input.is_action_just_pressed("left_click"):
		if level_manager != null:
			level_manager.next_level_path = "res://levels/lvl_select_screen.tscn"
			level_manager.go_to_next_level()

func _on_exit_mouse_exited():
	exit_icon.scale = Vector2(1, 1)


func _on_game_over_reload_mouse_exited():
	game_over_reload_sprite.scale = Vector2(1, 1)


func _on_win_reload_mouse_exited():
	win_reload_sprite.scale = Vector2(1, 1)


func _on_win_continue_mouse_exited():
	win_continue_sprite.scale = Vector2(1, 1)
