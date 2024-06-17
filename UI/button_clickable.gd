extends Area2D

@export var sprite_scene : PackedScene
@export var path : String
var sprite

func _ready():
	if sprite_scene:
		sprite = sprite_scene.instantiate()
		add_child(sprite)

func _on_input_event(_viewport, _event, _shape_idx):
	if sprite != null:
		sprite.position = Vector2(0, -10)
	if Input.is_action_just_pressed("left_click"):
		GameManager.goto_scene(path)

func _on_mouse_exited():
	if sprite != null:
		sprite.position = Vector2(0, 0)
