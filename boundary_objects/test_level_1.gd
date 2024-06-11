extends Node2D

var pathfinder : Node2D

func _ready():
	pathfinder = get_node_or_null("pathfinder")
	for child in get_children():
		if child.is_in_group("wall"):
			child.changed.connect(_on_wall_changed)

func _on_wall_changed():
	pathfinder.reset()
