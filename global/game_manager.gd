extends Node

var current_scene = null
var allowed_moves = 5
var move_list = Array()

var window_mode = 0

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

	GlobalTimer.wait_time = GlobalVariables.time_step
	GlobalTimer.timeout.emit()

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func save_game():
	var saved_game : SavedGame = SavedGame.new()
	
	saved_game.levels = GlobalVariables.levels.duplicate()
	saved_game.highscores = GlobalVariables.highscores.duplicate()
	
	ResourceSaver.save(saved_game, "user://savegame.tres")

func load_game():
	var saved_game : SavedGame
	if ResourceLoader.exists("user://savegame.tres"):
		saved_game = load("user://savegame.tres") as SavedGame
	else:
		return
	GlobalVariables.levels = saved_game.levels.duplicate()
	GlobalVariables.highscores = saved_game.highscores.duplicate()
