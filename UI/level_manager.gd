extends Node

var food_count := 0
var score := 0

func _ready():
	for collectible in get_tree().get_nodes_in_group("collectible"):
		collectible.collected.connect(_on_collectible_collected)
		food_count += 1

func _on_collectible_collected(_msg = {}):
	score +=1
	if score >= food_count:
		print("level_complete")
		await get_tree().create_timer(GlobalVariables.time_step / 2.0).timeout
		get_tree().reload_current_scene()
